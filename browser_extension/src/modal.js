function crownLinkGuardDetailsText(scan, url, ticketUrl) {
  return [
    "Please review this suspicious link:",
    "",
    "Ticket:",
    ticketUrl || window.location.href,
    "",
    "URL:",
    url,
    "",
    "Risk Level:",
    scan.risk_level,
    "",
    "Reasons:",
    ...(scan.reasons || [])
  ].join("\n");
}

async function crownLinkGuardCopy(text) {
  try {
    await navigator.clipboard.writeText(text);
  } catch (_error) {
    window.prompt("Copy these details", text);
  }
}

function crownLinkGuardShowModal(scan, url, onContinue) {
  const existing = document.getElementById("crown-link-guard-modal");
  if (existing) existing.remove();

  const isBlocked = scan.risk_level === "blocked";
  const isHigh = scan.risk_level === "high_risk";
  const title = isBlocked ? "Link blocked for your safety" : (isHigh ? "This link looks suspicious" : "Careful - this link may be unsafe");
  const body = isBlocked
    ? "This link has been blocked because it matches phishing indicators or the company blocklist."
    : "This link is not from a trusted or official domain. Phishing emails can look professional and may appear after a normal conversation.";
  const professionalWarning = "Even if the previous message looked normal, this new message contains a link. Phishers often start with a normal conversation, then send the malicious link later. Please verify before opening.";

  const overlay = document.createElement("div");
  overlay.id = "crown-link-guard-modal";
  overlay.innerHTML = `
    <div class="clg-backdrop"></div>
    <section class="clg-dialog" role="dialog" aria-modal="true">
      <h2>${title}</h2>
      <p>${body}</p>
      <p>${professionalWarning}</p>
      <dl>
        <dt>Domain</dt><dd>${scan.domain || "Unknown"}</dd>
        <dt>Risk level</dt><dd>${scan.risk_level} (${scan.risk_score})</dd>
      </dl>
      <ul>${(scan.reasons || []).map((reason) => `<li>${reason}</li>`).join("")}</ul>
      <div class="clg-actions"></div>
    </section>
  `;

  const style = document.createElement("style");
  style.textContent = `
    #crown-link-guard-modal .clg-backdrop { position: fixed; inset: 0; background: rgba(16, 27, 37, .62); z-index: 2147483646; }
    #crown-link-guard-modal .clg-dialog { position: fixed; z-index: 2147483647; top: 10vh; left: 50%; transform: translateX(-50%); width: min(560px, calc(100vw - 28px)); background: #fff; color: #17212b; border-radius: 8px; padding: 22px; box-shadow: 0 24px 70px rgba(0,0,0,.35); font-family: Arial, sans-serif; }
    #crown-link-guard-modal h2 { margin: 0 0 10px; font-size: 22px; }
    #crown-link-guard-modal p { margin: 9px 0; }
    #crown-link-guard-modal dl { display: grid; grid-template-columns: 100px 1fr; gap: 5px 12px; background: #f4f6f8; border-radius: 6px; padding: 12px; }
    #crown-link-guard-modal dt { color: #52616f; }
    #crown-link-guard-modal dd { margin: 0; word-break: break-word; }
    #crown-link-guard-modal li { margin: 5px 0; }
    #crown-link-guard-modal .clg-actions { display: flex; flex-wrap: wrap; gap: 8px; margin-top: 16px; }
    #crown-link-guard-modal button { border: 0; border-radius: 6px; padding: 9px 12px; cursor: pointer; background: #126b7f; color: #fff; font: inherit; }
    #crown-link-guard-modal button.secondary { background: #51606f; }
    #crown-link-guard-modal button.danger { background: #b42318; }
  `;
  overlay.appendChild(style);
  document.documentElement.appendChild(overlay);

  const actions = overlay.querySelector(".clg-actions");
  const ticketUrl = window.location.href;
  const details = crownLinkGuardDetailsText(scan, url, ticketUrl);
  const close = () => overlay.remove();
  const logAction = (action) => {
    if (scan.scan_id) crownLinkGuardRequest("/api/v1/actions", { scan_id: scan.scan_id, action_taken: action }).catch(() => {});
  };

  const addButton = (text, className, handler) => {
    const button = document.createElement("button");
    button.textContent = text;
    button.className = className || "";
    button.addEventListener("click", handler);
    actions.appendChild(button);
  };

  if (!isBlocked) addButton("Cancel", "secondary", () => { logAction("cancelled"); close(); });
  addButton("Ask Team Leader", "secondary", async () => { await crownLinkGuardCopy(details); logAction("asked_team_leader"); alert("Please ask your Team Leader before opening this link. Keep the ticket open and do not click the link until verified."); close(); });
  addButton("Ask Senior Agent", "secondary", async () => { await crownLinkGuardCopy(details); logAction("asked_senior_agent"); alert("Please ask a senior agent to review this ticket before opening the link."); close(); });
  addButton("Report to Ahmed", "danger", async () => {
    const config = await CrownLinkGuardConfig.get();
    await crownLinkGuardRequest("/api/v1/reports", {
      url,
      ticket_url: ticketUrl,
      ticket_id: crownLinkGuardTicketId(),
      agent_email: config.agentEmail,
      agent_name: config.agentName,
      agent_note: "Reported from the Crown Link Guard browser extension."
    });
    await crownLinkGuardCopy(`Hi Ahmed, I found a suspicious link in this Zoho Desk ticket. Please review it.\n\nTicket:\n${ticketUrl}\n\nURL:\n${url}`);
    logAction("reported");
    alert("Reported successfully. Please do not open the link until it is reviewed.");
    close();
  });
  addButton("Copy Details", "secondary", async () => { await crownLinkGuardCopy(details); logAction("copied_details"); });
  if (!isBlocked && !isHigh) addButton("Continue", "", () => { logAction("allowed"); close(); onContinue(); });
  if (isBlocked) addButton("Close", "secondary", close);
}
