class EventHandler {
  constructor (controller) {
    this.eventHandlers = []

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
    const targetMatching = options.matching
    const callback = options.with

    const handler = {
      listener (event) {
        if (targetMatching) {
          const target = event.target.closest(targetMatching)
          if (!target) { return }
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
