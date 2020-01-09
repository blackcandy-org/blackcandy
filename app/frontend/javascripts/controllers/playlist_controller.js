import { Controller } from 'stimulus';
import { ajax } from '@rails/ujs';

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
        url: `/playlists/${this.data.get('id')}`,
        type: 'put',
        data: `playlist[name]=${newName}`
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
}
