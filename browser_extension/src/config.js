var CrownLinkGuardConfig = {
  defaults: {
    apiUrl: "http://localhost:3000",
    apiToken: "dev-extension-token-change-me",
    agentEmail: "",
    agentName: ""
  },

  async get() {
    return new Promise((resolve) => {
      chrome.storage.sync.get(this.defaults, (value) => resolve(value));
    });
  },

  async set(values) {
    return new Promise((resolve) => chrome.storage.sync.set(values, resolve));
  }
};
