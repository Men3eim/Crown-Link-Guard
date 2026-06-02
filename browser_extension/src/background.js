importScripts("config.js");

chrome.runtime.onInstalled.addListener(() => {
  CrownLinkGuardConfig.get().then((config) => CrownLinkGuardConfig.set(config));
});
