async function crownLinkGuardRequest(path, body) {
  const config = await CrownLinkGuardConfig.get();
  const response = await fetch(`${config.apiUrl}${path}`, {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${config.apiToken}`,
      "Content-Type": "application/json"
    },
    body: JSON.stringify(body || {})
  });

  if (!response.ok) {
    throw new Error(`Crown Link Guard API returned ${response.status}`);
  }

  return response.json();
}

async function crownLinkGuardHealth() {
  const config = await CrownLinkGuardConfig.get();
  const response = await fetch(`${config.apiUrl}/api/v1/health`);
  return response.ok ? response.json() : { status: "offline" };
}
