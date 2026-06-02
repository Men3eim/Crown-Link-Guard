const crownLinkGuardSafeCache = new Map();
const CROWN_LINK_GUARD_CACHE_MS = 10 * 60 * 1000;

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

function crownLinkGuardOpen(url) {
  window.open(url, "_blank", "noopener");
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
    source: "zoho-desk-extension",
    hidden_link: crownLinkGuardHiddenLink(anchor)
  });
}

document.addEventListener("click", async (event) => {
  const anchor = event.target.closest && event.target.closest("a[href]");
  if (!anchor || !anchor.href || anchor.href.startsWith("mailto:") || anchor.href.startsWith("tel:")) return;

  event.preventDefault();
  event.stopPropagation();

  const url = anchor.href;
  if (crownLinkGuardIsSafeCached(url)) {
    crownLinkGuardOpen(url);
    return;
  }

  try {
    const scan = await crownLinkGuardScan(url, anchor);
    chrome.storage.local.set({ lastScannedUrl: url, lastRiskLevel: scan.risk_level });

    if (scan.risk_level === "safe") {
      crownLinkGuardSafeCache.set(url, Date.now() + CROWN_LINK_GUARD_CACHE_MS);
      crownLinkGuardOpen(url);
      return;
    }

    crownLinkGuardShowModal(scan, url, () => crownLinkGuardOpen(url));
  } catch (_error) {
    crownLinkGuardShowModal({
      risk_level: "high_risk",
      risk_score: 70,
      domain: new URL(url).hostname,
      reasons: ["Crown Link Guard backend is offline. Please verify this link manually before opening."]
    }, url, () => {});
  }
}, true);
