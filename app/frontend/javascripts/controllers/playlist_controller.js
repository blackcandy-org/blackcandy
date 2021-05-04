import { Controller } from 'stimulus';
import { fetchRequest } from '../helper';

export default class extends Controller {
  static targets = ['name', 'nameInput'];

  static values = {
    id: Number
  }

  rename() {
    const name = this.nameTarget.innerText;

    this.nameTarget.classList.add('u-display-none');
    this.nameInputTarget.classList.remove('u-display-none');
    this.nameInputTarget.value = name;
    this.nameInputTarget.focus();
    this.nameInputTarget.select();
  }

  updateName() {
    const newName = this.nameInputTarget.value.trim();

    if (newName != this.nameTarget.innerText && newName != '') {
      this.nameTarget.innerText = newName;

      fetchRequest(`/playlists/${this.idValue}`, {
        method: 'put',
        body: JSON.stringify({
          playlist: {
            name: newName
          }
        })
      });
    }

    this.nameTarget.classList.remove('u-display-none');
    this.nameInputTarget.classList.add('u-display-none');
  }

  updateNameOnEnter(event) {
    if (event.key == 'Enter') {
      this.updateName();
    }
  }
}
