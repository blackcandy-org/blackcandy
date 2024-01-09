class EventHandler {
  constructor (controller) {
    this.eventHandlers = []
    this.identifier = controller.scope.identifier

    const controllerDisconnectCallback = controller.disconnect.bind(controller)

    Object.assign(controller, {
      handleEvent: this.handleEvent,
      removeHandledEvents: this.removeHandledEvents,
      disconnect () {
        controllerDisconnectCallback()
        this.removeHandledEvents()
      }
    })
  }

  handleEvent = (type, options = {}) => {
    const element = options.on || document
    const isDelegation = options.delegation
    const callback = options.with
    const identifier = this.identifier

    const handler = {
      listener (event) {
        if (isDelegation) {
          if (event.target.dataset.preventDelegation) { return }

          const targetSelector = `[data-delegated-action~='${type}->${identifier}#${callback.name}']`
          if (!event.target.closest(targetSelector)) { return }
        }

        callback(event)
      },

      removeListener () {
        element.removeEventListener(type, this.listener)
      }
    }

    element.addEventListener(type, handler.listener)

    this.eventHandlers.push(handler)
  }

  removeHandledEvents = () => {
    this.eventHandlers.forEach((handler) => handler.removeListener())
    this.eventHandlers = []
  }
}

export const installEventHandler = (controller) => {
  return new EventHandler(controller)
}
