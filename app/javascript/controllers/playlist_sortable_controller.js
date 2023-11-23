import { Controller } from '@hotwired/stimulus'
import { fetchRequest } from '../helper'

export default class extends Controller {
  connect () {
    this.dragHandle = null

    this.element.addEventListener('mousedown', this.#handleMouseDown)
    this.element.addEventListener('dragstart', this.#handleDragStart)
    this.element.addEventListener('dragenter', this.#handleDragEnter)
    this.element.addEventListener('dragleave', this.#handleDragLeave)
    this.element.addEventListener('dragend', this.#handleDragEnd)
    this.element.addEventListener('dragover', this.#handleDragOver)
    this.element.addEventListener('drop', this.#handleDrop)
  }

  disconnect () {
    this.element.removeEventListener('mousedown', this.#handleMouseDown)
    this.element.removeEventListener('dragstart', this.#handleDragStart)
    this.element.removeEventListener('dragenter', this.#handleDragEnter)
    this.element.removeEventListener('dragleave', this.#handleDragLeave)
    this.element.removeEventListener('dragend', this.#handleDragEnd)
    this.element.removeEventListener('dragover', this.#handleDragOver)
    this.element.removeEventListener('drop', this.#handleDrop)
  }

  #handleMouseDown = (event) => {
    const handle = event.target.closest('.js-playlist-sortable-item-handle')

    if (handle) {
      this.dragHandle = handle
    } else {
      this.dragHandle = null
    }
  }

  #handleDragStart = (event) => {
    const target = event.target

    if (!target.draggable || !target.contains(this.dragHandle)) {
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

    sourceElement.remove()

    if (sourceIndex < targetIndex) {
      target.insertAdjacentElement('afterend', sourceElement)
    } else {
      target.insertAdjacentElement('beforebegin', sourceElement)
    }

    fetchRequest(`/playlists/${playlistId}/songs/${songId}/`, {
      method: 'put',
      body: JSON.stringify({
        destination_song_id: destinationSongId
      })
    })
  }
}
