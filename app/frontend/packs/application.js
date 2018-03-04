/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

import RailsUjs from 'rails-ujs';
import Turbolinks from 'turbolinks';
import * as ActiveStorage from 'activestorage';
import { Application } from 'stimulus';
import { definitionsFromContext } from 'stimulus/webpack-helpers';

import 'babel-polyfill';
import 'whatwg-fetch';

import 'normalize.css';
import 'notie/dist/notie.css';
import '../stylesheets/application.css';

RailsUjs.start();
Turbolinks.start();
ActiveStorage.start();

const application = Application.start();
const controllers = require.context('../javascripts/controllers', true, /\.js$/);

application.load(definitionsFromContext(controllers));
