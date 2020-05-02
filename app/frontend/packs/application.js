/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

import RailsUjs from '@rails/ujs';
import Turbolinks from 'turbolinks';
import { Application } from 'stimulus';
import { definitionsFromContext } from 'stimulus/webpack-helpers';
import App from '../javascripts/app';
import Player from '../javascripts/player';

import 'core-js/stable';
import 'regenerator-runtime/runtime';

require.context('../images', true);

RailsUjs.start();
Turbolinks.start();

const application = Application.start();
const controllers = require.context('../javascripts/controllers', true, /\.js$/);

application.load(definitionsFromContext(controllers));

window.App = App;
window.App.player = new Player();
