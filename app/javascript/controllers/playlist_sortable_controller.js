import { Controller } from '@hotwired/stimulus'
import { fetchRequest } from '../helper'
import { installEventHandler } from './mixins/event_handler'

export default class extends Controller {
  DRAG_HANDLE_SELECTOR = '.js-playlist-sortable-item-handle'

  initialize () {
    installEventHandler(this)
  }

  connect () {
    this.dragHandle = null

    this.handleEvent('mousedown', {
      on: this.element,
      with: this.#handleMouseDown
    })

    this.handleEvent('dragstart', {
      on: this.element,
      with: this.#handleDragStart
    })

    this.handleEvent('dragenter', {
      on: this.element,
      with: this.#handleDragEnter
    })

    this.handleEvent('dragleave', {
      on: this.element,
      with: this.#handleDragLeave
    })

    this.handleEvent('dragend', {
      on: this.element,
      with: this.#handleDragEnd
    })

    this.handleEvent('dragover', {
      on: this.element,
      with: this.#handleDragOver
    })

    this.handleEvent('drop', {
      on: this.element,
      with: this.#handleDrop
    })
  }

  #handleMouseDown = (event) => {
    const handle = event.target.closest(this.DRAG_HANDLE_SELECTOR)

    if (handle) {
      this.dragHandle = handle
    } else {
      this.dragHandle = null
    }
  }

  #handleDragStart = (event) => {
    const target = event.target
    const handleExists = target.querySelector(this.DRAG_HANDLE_SELECTOR)

    if (!target.draggable || (handleExists && !target.contains(this.dragHandle))) {
      event.preventDefault()
      return
    }

    target.classList.add('is-dragging-source')
    event.currentTarget.classList.add('is-dragging')
    event.dataTransfer.effectAllowed = 'move'
    event.dataTransfer.setData('text/plain', target.id)
  }

  #handleDragEnter = (event) => {
    const target = event.target.closest('[draggable="true"]')

    if (target) {
      target.classList.add('is-dragging-over')
    }
  }

  #handleDragLeave = (event) => {
    const target = event.target.closest('[draggable="true"]')

    if (target) {
      target.classList.remove('is-dragging-over')
    }
  }

  #handleDragEnd = (event) => {
    event.currentTarget.classList.remove('is-dragging')
    event.target.classList.remove('is-dragging-source')
  }

  #handleDragOver = (event) => {
    event.preventDefault()
    event.dataTransfer.dropEffect = 'move'
  }

  #handleDrop = (event) => {
    event.stopPropagation()

    const elementId = event.dataTransfer.getData('text/plain')
    const target = event.target.closest('[draggable="true"]')

    target.classList.remove('is-dragging-over')

    if (target.id === elementId) { return }

    const sourceElement = document.getElementById(elementId)
    const sourceIndex = Array.from(sourceElement.parentNode.children).indexOf(sourceElement)
    const targetIndex = Array.from(target.parentNode.children).indexOf(target)
    const songId = sourceElement.dataset.songId
    const destinationSongId = target.dataset.songId
    const playlistId = this.element.dataset.playlistId

    if (sourceIndex < targetIndex) {
      target.after(sourceElement)
    } else {
      target.before(sourceElement)
    }

    fetchRequest(`/playlists/${playlistId}/songs/${songId}/move`, {
      method: 'put',
      body: JSON.stringify({
        destination_song_id: destinationSongId
      })
    })
  }
}
