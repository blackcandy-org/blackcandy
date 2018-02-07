import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['name']

  greet() {
    console.log(`Hello, ${this.name} ${this.element}`);
  }

  get name() {
    return this.nameTarget.value;
  }
}
