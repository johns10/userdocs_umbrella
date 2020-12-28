// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"
import {Socket} from "phoenix"
import NProgress from "nprogress"
import {LiveSocket} from "phoenix_live_view"
import {handle_message} from "./commands.js"
import {Hooks} from "./hooks.js"

let DOMAIN = "user-docs.com"
let PORT = "4003"

let APP_URL = "https://" + DOMAIN + ":" + PORT + "/"
let WEBSOCKETS_URI = "wss://" + DOMAIN + ":" + PORT + "/live"

try {
  chrome.runtime.onMessage.addListener(
    function(message, sender, sendResponse) {
      console.log("Extension received message")
      console.log(sender.tab ?
                "from a content script:" + sender.tab.url :
                "from the extension");
              
    console.log("handling message in the listener")
    handle_message(message, { environment: 'extension' })
  });
} catch(e) {
  console.log("Failed to add listener")
  console.log(e)
  console.log(chrome.runtime)
}

var xhr = new XMLHttpRequest();
xhr.responseType = 'document';
xhr.open('GET', APP_URL, true)
xhr.onload = function(e) {
  document.documentElement.replaceChild(this.response.head, document.head)
  document.documentElement.replaceChild(this.response.body, document.body)
  
  let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

  let liveSocket = new LiveSocket(WEBSOCKETS_URI, Socket, {
    params: { _csrf_token: csrfToken},
    hooks: Hooks
  })
  
  window.addEventListener("phx:page-loading-start", info => NProgress.start())
  window.addEventListener("phx:page-loading-stop", info => NProgress.done())
  
  liveSocket.connect()
  
  window.liveSocket = liveSocket
}
xhr.send()