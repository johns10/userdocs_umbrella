(async () => {
  const src = chrome.extension.getURL('browser_bundle.js');
  const contentScript = await import(src);
  contentScript.main();
})();
