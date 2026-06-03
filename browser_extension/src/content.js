const crownLinkGuardSafeCache = new Map();
const CROWN_LINK_GUARD_CACHE_MS = 10 * 60 * 1000;
const CROWN_LINK_GUARD_IGNORED_HOSTS = ["localhost", "127.0.0.1", "::1"];

function crownLinkGuardTicketId() {
  const match = window.location.href.match(/tickets\/(\d+)/i) || window.location.href.match(/[?&]ticketId=(\d+)/i);
  return match ? match[1] : "";
}

function crownLinkGuardIsSafeCached(url) {
  const expiresAt = crownLinkGuardSafeCache.get(url);
  if (!expiresAt) return false;
  if (Date.now() > expiresAt) {
    crownLinkGuardSafeCache.delete(url);
    return false;
  }
  return true;
}

function crownLinkGuardOpen(url, anchor) {
  if (anchor && (anchor.target === "_blank" || eventMetaKeyPressed(anchor))) {
    window.open(url, "_blank", "noopener");
  } else {
    window.location.assign(url);
  }
}

function eventMetaKeyPressed(anchor) {
  return anchor.dataset.crownLinkGuardOpenNewTab === "true";
}

function crownLinkGuardIgnoredHost(hostname) {
  return CROWN_LINK_GUARD_IGNORED_HOSTS.includes(hostname);
}

function crownLinkGuardShouldScan(anchor, event) {
  const rawHref = anchor.getAttribute("href") || "";
  const trimmedHref = rawHref.trim().toLowerCase();

  if (!trimmedHref || trimmedHref.startsWith("#")) return false;
  if (trimmedHref.startsWith("mailto:") || trimmedHref.startsWith("tel:")) return false;
  if (trimmedHref.startsWith("javascript:") || trimmedHref.startsWith("void(")) return false;

  let destination;
  try {
    destination = new URL(anchor.href, window.location.href);
  } catch (_error) {
    return false;
  }

  if (!["http:", "https:"].includes(destination.protocol)) return false;
  if (destination.origin === window.location.origin) return false;
  if (crownLinkGuardIgnoredHost(destination.hostname)) return false;
  if (event && event.defaultPrevented) return false;

  return true;
}

function crownLinkGuardHiddenLink(anchor) {
  return Boolean(anchor.querySelector("img, button, svg")) || !anchor.textContent.trim().includes(anchor.href);
}

async function crownLinkGuardScan(url, anchor) {
  const config = await CrownLinkGuardConfig.get();
  return crownLinkGuardRequest("/api/v1/scan_url", {
    url,
    ticket_url: window.location.href,
    ticket_id: crownLinkGuardTicketId(),
    agent_email: config.agentEmail,
    agent_name: config.agentName,
    source: "browser-wide-extension",
    hidden_link: crownLinkGuardHiddenLink(anchor)
  });
}

document.addEventListener("click", async (event) => {
  const anchor = event.target.closest && event.target.closest("a[href]");
  if (!anchor || !crownLinkGuardShouldScan(anchor, event)) return;

  event.preventDefault();
  event.stopPropagation();
  anchor.dataset.crownLinkGuardOpenNewTab = (event.metaKey || event.ctrlKey || event.shiftKey || event.button === 1) ? "true" : "false";

  const url = anchor.href;
  if (crownLinkGuardIsSafeCached(url)) {
    crownLinkGuardOpen(url, anchor);
    return;
  }

  try {
    const scan = await crownLinkGuardScan(url, anchor);
    chrome.storage.local.set({ lastScannedUrl: url, lastRiskLevel: scan.risk_level });

    if (scan.risk_level === "safe") {
      crownLinkGuardSafeCache.set(url, Date.now() + CROWN_LINK_GUARD_CACHE_MS);
      crownLinkGuardOpen(url, anchor);
      return;
    }

    crownLinkGuardShowModal(scan, url, () => crownLinkGuardOpen(url, anchor));
  } catch (_error) {
    crownLinkGuardShowModal({
      risk_level: "high_risk",
      risk_score: 70,
      domain: new URL(url).hostname,
      reasons: ["Crown Link Guard backend is offline. Please verify this link manually before opening."]
    }, url, () => {});
  }
}, true);
