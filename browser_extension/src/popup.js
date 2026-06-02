async function renderPopup() {
  const config = await CrownLinkGuardConfig.get();
  const local = await new Promise((resolve) => chrome.storage.local.get({ lastScannedUrl: "", lastRiskLevel: "" }, resolve));
  let health = { status: "offline" };

  try {
    health = await crownLinkGuardHealth();
  } catch (_error) {
    health = { status: "offline" };
  }

  document.getElementById("status").textContent = health.status === "ok" ? "Online" : "Offline";
  document.getElementById("apiUrl").value = config.apiUrl;
  document.getElementById("apiToken").value = config.apiToken;
  document.getElementById("agentEmail").value = config.agentEmail;
  document.getElementById("agentName").value = config.agentName;
  document.getElementById("lastScanned").textContent = local.lastScannedUrl || "No scans yet";
  document.getElementById("lastRisk").textContent = local.lastRiskLevel || "-";
}

document.addEventListener("DOMContentLoaded", () => {
  renderPopup();
  document.getElementById("settings").addEventListener("submit", async (event) => {
    event.preventDefault();
    await CrownLinkGuardConfig.set({
      apiUrl: document.getElementById("apiUrl").value,
      apiToken: document.getElementById("apiToken").value,
      agentEmail: document.getElementById("agentEmail").value,
      agentName: document.getElementById("agentName").value
    });
    renderPopup();
  });
});
