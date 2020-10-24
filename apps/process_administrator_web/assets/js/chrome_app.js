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
import {Hooks} from "./commands.js"

let DOMAIN = "app.davenport.rocks"
let PORT = "4001"

let APP_URL = "http://" + DOMAIN + ":" + PORT + "/"
let WEBSOCKETS_URI = "ws://" + DOMAIN + ":" + PORT + "/live"
let COOKIE_KEY = "_process_administrator_web_key"

chrome.runtime.onMessage.addListener(
	function(message, sender, sendResponse) {
    console.log("Extension received message")
		console.log(sender.tab ?
							"from a content script:" + sender.tab.url :
              "from the extension");
            
  console.log("handling message in the listener")
  handle_message(message, { environment: 'extension' })
});

const updateEvent = new CustomEvent('update', {
  bubbles: false,
  detail: {  }
});

console.log("Before xhr cookie")
console.log((' ' + document.cookie).slice(1))

var xhr = new XMLHttpRequest();
xhr.responseType = 'document';
xhr.open('GET', APP_URL, true)
xhr.onload = function(e) {
  document.documentElement.replaceChild(this.response.head, document.head)
  document.documentElement.replaceChild(this.response.body, document.body)

  console.log("After xhrc cookie")
  console.log((' ' + document.cookie).slice(1))

  let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
  let newCookie = document.querySelector("[data-phx-main='true']").getAttribute("data-phx-session")

  console.log(newCookie)
  console.log(csrfToken)

  /*
  let newCookieString = COOKIE_KEY + "=" + newCookie + ";domain=.davenport.rocks;";
  console.log(newCookieString)

  document.cookie = newCookieString
  */

  console.log("After setting cookie")
  console.log(document.cookie)

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