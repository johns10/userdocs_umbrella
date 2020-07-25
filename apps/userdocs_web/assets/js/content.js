(async () => {
  const src = chrome.extension.getURL('browser.js');
  const contentScript = await import(src);
  contentScript.main();
})();
