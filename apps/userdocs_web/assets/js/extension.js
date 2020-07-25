chrome.runtime.onMessage.addListener(
	function(request, sender, sendResponse) {
    console.log("Extension received message")
		console.log(sender.tab ?
							"from a content script:" + sender.tab.url :
							"from the extension");
	if (request.command == "setSelector") {
    result = setSelector(request.selector);
		sendResponse({result: result});
	}
});

function setSelector(value) {
  try {
    console.log("setting selector")
    console.log(value)
    var element = document.getElementById("element_selector")
    console.log(element)
    element.value = value;
    return true
  }
  catch(error) {
    console.log(error)
    return false
  }
}