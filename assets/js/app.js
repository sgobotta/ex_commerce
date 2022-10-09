import "phoenix_html"
import {LiveSocket} from "phoenix_live_view"
import {Socket} from "phoenix"
import {createLiveMotion} from 'live_motion';
import topbar from "topbar"

const isVisible = el =>
  !!(el.offsetWidth || el.offsetHeight || el.getClientRects().length > 0)

const execJS = (selector, attr) => {
  document
  .querySelectorAll(selector)
  .forEach(el => liveSocket.execJS(el, el.getAttribute(attr)))
}

const {hook: motionHook, handleMotionUpdates} = createLiveMotion();

const Hooks = {}

Hooks.Flash = {
  destroyed(){ clearTimeout(this.timer) },
  mounted(){
    const hide = () => liveSocket.execJS(
      this.el,
      this.el.getAttribute("phx-click")
    )
    this.timer = setTimeout(() => hide(), 8000)
    this.el.addEventListener("phx:hide-start", () => clearTimeout(this.timer))
    this.el.addEventListener("mouseover", () => {
      clearTimeout(this.timer)
      this.timer = setTimeout(() => hide(), 8000)
    })
  }
}

Hooks.Menu = {
  activate(index, fallbackIndex){
    const menuItems = this.menuItems()
    this.activeItem = menuItems[index] || menuItems[fallbackIndex]
    this.activeItem.classList.add(this.activeClass)
    this.activeItem.focus()
  },
  deactivate(items){
    items.forEach(item => item.classList.remove(this.activeClass))
  },
  destroyed(){ this.reset() },
  getAttr(name){
    const val = this.el.getAttribute(name)
    if (val === null){
      throw (new Error(`no ${name} attribute configured for menu`))
    }
    return val
  },
  menuItems() {
    return Array.from(
      this.menuItemsContainer.querySelectorAll("[role=menuitem]")
    )
  },
  mounted() {
    this.menuItemsContainer = document.querySelector(
      `[aria-labelledby="${this.el.id}"]`
    )
    this.reset()
    this.handleKeyDown = (e) => this.onKeyDown(e)
    this.el.addEventListener("keydown", e => {
      if (
        (e.key === "Enter" || e.key === " ")
        && e.currentTarget.isSameNode(this.el)
      ) {
        this.enabled = true
      }
    })
    this.el.addEventListener("click", e => {
      if (!e.currentTarget.isSameNode(this.el)){ return }

      window.addEventListener("keydown", this.handleKeyDown)
      // disable if button clicked and click was not a keyboard event
      if (this.enabled){
        window.requestAnimationFrame(() => this.activate(0))
      }
    })
    this.menuItemsContainer.addEventListener("phx:hide-start", () => {
      return this.reset()
    })
  },
  onKeyDown(e) {
    if (e.key === "Escape"){
      document.body.click()
      this.el.focus()
      this.reset()
    } else if (e.key === "Enter" && !this.activeItem){
      this.activate(0)
    } else if (e.key === "Enter"){
      this.activeItem.click()
    }
    if (e.key === "ArrowDown"){
      e.preventDefault()
      const menuItems = this.menuItems()
      this.deactivate(menuItems)
      this.activate(menuItems.indexOf(this.activeItem) + 1, 0)
    } else if (e.key === "ArrowUp"){
      e.preventDefault()
      const menuItems = this.menuItems()
      this.deactivate(menuItems)
      this.activate(
        menuItems.indexOf(this.activeItem) - 1,
        menuItems.length - 1
      )
    } else if (e.key === "Tab"){
      e.preventDefault()
    }
  },
  reset() {
    this.enabled = false
    this.activeClass = this.getAttr("data-active-class")
    this.deactivate(this.menuItems())
    this.activeItem = null
    window.removeEventListener("keydown", this.handleKeyDown)
  }
}

// Accessible focus handling
const Focus = {
  // Subject to the W3C Software License at
  // https://www.w3.org/Consortium/Legal/2015/copyright-software-and-document
  attemptFocus(el) {
    if (!el){ return }
    if (!this.isFocusable(el)){ return false }
    try {
      el.focus()
    }
    catch (e) {
      console.error(e)
    }

    return document.activeElement === el
  },
  // Subject to the W3C Software License at
  // https://www.w3.org/Consortium/Legal/2015/copyright-software-and-document
  focusFirstDescendant(el){
    for (let i = 0; i < el.childNodes.length; i++) {
      const child = el.childNodes[i]
      if (this.attemptFocus(child) || this.focusFirstDescendant(child)) {
        return true
      }
    }
    return false
  },
  // Subject to the W3C Software License at
  // https://www.w3.org/Consortium/Legal/2015/copyright-software-and-document
  focusLastDescendant(element){
    for (let i = element.childNodes.length - 1; i >= 0; i--){
      const child = element.childNodes[i]
      if (this.attemptFocus(child) || this.focusLastDescendant(child)) {
        return true
      }
    }
    return false
  },
  focusMain(){
    const target = document
      .querySelector("main h1") || document.querySelector("main")
    if (target) {
      const origTabIndex = target.tabIndex
      target.tabIndex = -1
      target.focus()
      target.tabIndex = origTabIndex
    }
  },
  // Subject to the W3C Software License at
  // https://www.w3.org/Consortium/Legal/2015/copyright-software-and-document
  isFocusable(el) {
    if (
      el.tabIndex > 0 ||
      (el.tabIndex === 0 && el.getAttribute("tabIndex") !== null)
    ) {
        return true
    }
    if (el.disabled) {
      return false
    }

    switch (el.nodeName) {
      case "A":
        return !!el.href && el.rel !== "ignore"
      case "INPUT":
        return el.type !== "hidden" && el.type !== "file"
      case "BUTTON":
      case "SELECT":
      case "TEXTAREA":
        return true
      default:
        return false
    }
  }
}

// Accessible focus wrapping
Hooks.FocusWrap = {
  mounted(){
    this.content = document.querySelector(this.el.getAttribute("data-content"))
    this.focusStart = this.el.querySelector(`#${this.el.id}-start`)
    this.focusEnd = this.el.querySelector(`#${this.el.id}-end`)
    this.focusStart.addEventListener(
      "focus", () => Focus.focusLastDescendant(this.content)
    )
    this.focusEnd.addEventListener(
      "focus", () => Focus.focusFirstDescendant(this.content)
    )
    this.content.addEventListener(
      "phx:show-end", () => this.content.focus()
    )
    if (window.getComputedStyle(this.content).display !== "none") {
      Focus.focusFirstDescendant(this.content)
    }
  }
}

const csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content")
const liveSocket = new LiveSocket(
  "/live",
  Socket,
  {
    dom: {
      onBeforeElUpdated(from, to) {
        // add this line
        handleMotionUpdates(from, to);
      },
      onNodeAdded(node){
        if (node instanceof HTMLElement && node.autofocus){
          node.focus()
        }
      }
    },
    hooks: {
      ...motionHook,
      ...Hooks
    },
    params: {_csrf_token: csrfToken}
  }
)

const routeUpdated = () => {
  Focus.focusMain()
}

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", () => topbar.show())
window.addEventListener("phx:page-loading-stop", () => topbar.hide())
// Accessible routing
window.addEventListener("phx:page-loading-stop", e => routeUpdated(e.detail))

window.addEventListener(
  "js:exec",
  e => e.target[e.detail.call](...e.detail.args)
)
window.addEventListener(
  "js:focus", e => {
      const parent = document.querySelector(e.detail.parent)
      if (parent && isVisible(parent)) { e.target.focus() }
  }
)
window.addEventListener("js:focus-closest", e => {
  const el = e.target
  let sibling = el.nextElementSibling
  while (sibling){
    if (isVisible(sibling) && Focus.attemptFocus(sibling)){ return }
    sibling = sibling.nextElementSibling
  }
  sibling = el.previousElementSibling
  while (sibling){
    if (isVisible(sibling) && Focus.attemptFocus(sibling)){ return }
    sibling = sibling.previousElementSibling
  }
  Focus.attemptFocus(el.parent) || Focus.focusMain()
})
window.addEventListener(
  "phx:remove-el",
  e => document.getElementById(e.detail.id).remove()
)

// connect if there are any LiveViews on the page
liveSocket.getSocket().onOpen(() => execJS("#connection-status", "js-hide"))
liveSocket.getSocket().onError(() => execJS("#connection-status", "js-show"))
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency
// simulation:
//
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser
//    session
// >> liveSocket.disableLatencySim()
//
window.liveSocket = liveSocket
