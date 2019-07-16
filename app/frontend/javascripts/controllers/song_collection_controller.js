import { Controller } from 'stimulus';
import { ajax } from 'rails-ujs';

export default class extends Controller {
  static targets = ['name', 'nameInput'];

  rename() {
    const name = this.nameTarget.innerText;

    this.nameTarget.classList.add('hidden');
    this.nameInputTarget.classList.remove('hidden');
    this.nameInputTarget.value = name;
    this.nameInputTarget.focus();
    this.nameInputTarget.select();
  }

  updateName() {
    const newName = this.nameInputTarget.value.trim();

    if (newName != this.nameTarget.innerText && newName != '') {
      this.nameTarget.innerText = newName;

      ajax({
        url: `/song_collections/${this.data.get('id')}`,
        type: 'put',
        data: `song_collection[name]=${newName}`
      });
    }

    this.nameTarget.classList.remove('hidden');
    this.nameInputTarget.classList.add('hidden');
  }

  updateNameOnEnter(event) {
    if (event.key == 'Enter') {
      this.updateName();
    }
  }

  add({ target, currentTarget }) {
    const { songId } = currentTarget.dataset;
    const { songCollectionId } = target.closest('[data-song-collection-id]').dataset;

    App.dispatchEvent('#js-dialog-loader', 'loader:show');

    ajax({
      url: `/playlist/${songCollectionId}`,
      type: 'put',
      data: `update_action=push&song_id=${songId}`,
      success: () => {
        App.dispatchEvent('#js-dialog', 'dialog:hide');
      }
    });
  }
}
