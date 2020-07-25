userDocsExtensionId = 'hfgglmmpokiccigccbmoehlbbijaocpd';

var extensionWindowId = null
var extensionTabId = null

chrome.tabs.onUpdated.addListener(function(tabId) {
	chrome.pageAction.show(tabId);
});

chrome.tabs.getSelected(null, function(tab) {
	chrome.pageAction.show(tab.id);
});
/*
chrome.runtime.onMessage.addListener(
	function(request, sender, sendResponse) {
		console.log(sender.tab ?
							"from a content script: " + sender.tab.url :
							"from the extension");
	if (request.command == "setSelector") {
		console.log(request);
		chrome.storage.local.get(['extensionTabId'], function(result) {
			chrome.tabs.sendMessage(result.extensionTabId, request);
		});
		sendResponse({farewell: "goodbye"});
	} else if (request.command == "register") {
		sendResponse({result: "registered"});
	}
});
	*/
// This is where you set opening the extension
chrome.pageAction.onClicked.addListener(function(tab) {
	console.log(tab)
	chrome.storage.local.set({activeTabId: tab.id}, function() {
		console.log('activeTabId is set to ' + tab.id);
	});
	chrome.storage.local.set({activeWindowId: tab.windowId}, function() {
		console.log('activeWindowId is set to ' + tab.windowId);
	});
	chrome.windows.create({
		url: chrome.runtime.getURL("index.html"),
		type: "popup"},
			function(window) {
				chrome.storage.local.set({extensionWindowId: window.id}, function() {
          console.log('extensionWindowId is set to ' + window.id);
        });
				chrome.storage.local.set({extensionTabId: window.tabs[0].id}, function() {
          console.log('extensionTabId is set to ' + window.tabs[0].id);
        });
			});
});

console.log( 'Background.html done.' );