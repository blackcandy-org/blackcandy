var e="undefined"!==typeof globalThis?globalThis:"undefined"!==typeof self?self:global;var n={};(function(){var HowlerGlobal=function(){this.init()};HowlerGlobal.prototype={init:function(){var n=this||e||t;n._counter=1e3;n._html5AudioPool=[];n.html5PoolSize=10;n._codecs={};n._howls=[];n._muted=false;n._volume=1;n._canPlayEvent="canplaythrough";n._navigator="undefined"!==typeof window&&window.navigator?window.navigator:null;n.masterGain=null;n.noAudio=false;n.usingWebAudio=true;n.autoSuspend=true;n.ctx=null;n.autoUnlock=true;n._setup();return n},
/**
     * Get/set the global volume for all sounds.
     * @param  {Float} vol Volume from 0.0 to 1.0.
     * @return {Howler/Float}     Returns self or current volume.
     */
volume:function(n){var o=this||e||t;n=parseFloat(n);o.ctx||setupAudioContext();if("undefined"!==typeof n&&n>=0&&n<=1){o._volume=n;if(o._muted)return o;o.usingWebAudio&&o.masterGain.gain.setValueAtTime(n,t.ctx.currentTime);for(var r=0;r<o._howls.length;r++)if(!o._howls[r]._webAudio){var a=o._howls[r]._getSoundIds();for(var i=0;i<a.length;i++){var u=o._howls[r]._soundById(a[i]);u&&u._node&&(u._node.volume=u._volume*n)}}return o}return o._volume},
/**
     * Handle muting and unmuting globally.
     * @param  {Boolean} muted Is muted or not.
     */
mute:function(n){var o=this||e||t;o.ctx||setupAudioContext();o._muted=n;o.usingWebAudio&&o.masterGain.gain.setValueAtTime(n?0:o._volume,t.ctx.currentTime);for(var r=0;r<o._howls.length;r++)if(!o._howls[r]._webAudio){var a=o._howls[r]._getSoundIds();for(var i=0;i<a.length;i++){var u=o._howls[r]._soundById(a[i]);u&&u._node&&(u._node.muted=!!n||u._muted)}}return o},stop:function(){var n=this||e||t;for(var o=0;o<n._howls.length;o++)n._howls[o].stop();return n},unload:function(){var n=this||e||t;for(var o=n._howls.length-1;o>=0;o--)n._howls[o].unload();if(n.usingWebAudio&&n.ctx&&"undefined"!==typeof n.ctx.close){n.ctx.close();n.ctx=null;setupAudioContext()}return n},
/**
     * Check for codec support of specific extension.
     * @param  {String} ext Audio file extention.
     * @return {Boolean}
     */
codecs:function(n){return(this||e||t)._codecs[n.replace(/^x-/,"")]},_setup:function(){var n=this||e||t;n.state=n.ctx&&n.ctx.state||"suspended";n._autoSuspend();if(!n.usingWebAudio)if("undefined"!==typeof Audio)try{var o=new Audio;"undefined"===typeof o.oncanplaythrough&&(n._canPlayEvent="canplay")}catch(e){n.noAudio=true}else n.noAudio=true;try{o=new Audio;o.muted&&(n.noAudio=true)}catch(e){}n.noAudio||n._setupCodecs();return n},_setupCodecs:function(){var n=this||e||t;var o=null;try{o="undefined"!==typeof Audio?new Audio:null}catch(e){return n}if(!o||"function"!==typeof o.canPlayType)return n;var r=o.canPlayType("audio/mpeg;").replace(/^no$/,"");var a=n._navigator?n._navigator.userAgent:"";var i=a.match(/OPR\/([0-6].)/g);var u=i&&parseInt(i[0].split("/")[1],10)<33;var d=-1!==a.indexOf("Safari")&&-1===a.indexOf("Chrome");var s=a.match(/Version\/(.*?) /);var _=d&&s&&parseInt(s[1],10)<15;n._codecs={mp3:!!(!u&&(r||o.canPlayType("audio/mp3;").replace(/^no$/,""))),mpeg:!!r,opus:!!o.canPlayType('audio/ogg; codecs="opus"').replace(/^no$/,""),ogg:!!o.canPlayType('audio/ogg; codecs="vorbis"').replace(/^no$/,""),oga:!!o.canPlayType('audio/ogg; codecs="vorbis"').replace(/^no$/,""),wav:!!(o.canPlayType('audio/wav; codecs="1"')||o.canPlayType("audio/wav")).replace(/^no$/,""),aac:!!o.canPlayType("audio/aac;").replace(/^no$/,""),caf:!!o.canPlayType("audio/x-caf;").replace(/^no$/,""),m4a:!!(o.canPlayType("audio/x-m4a;")||o.canPlayType("audio/m4a;")||o.canPlayType("audio/aac;")).replace(/^no$/,""),m4b:!!(o.canPlayType("audio/x-m4b;")||o.canPlayType("audio/m4b;")||o.canPlayType("audio/aac;")).replace(/^no$/,""),mp4:!!(o.canPlayType("audio/x-mp4;")||o.canPlayType("audio/mp4;")||o.canPlayType("audio/aac;")).replace(/^no$/,""),weba:!!(!_&&o.canPlayType('audio/webm; codecs="vorbis"').replace(/^no$/,"")),webm:!!(!_&&o.canPlayType('audio/webm; codecs="vorbis"').replace(/^no$/,"")),dolby:!!o.canPlayType('audio/mp4; codecs="ec-3"').replace(/^no$/,""),flac:!!(o.canPlayType("audio/x-flac;")||o.canPlayType("audio/flac;")).replace(/^no$/,"")};return n},_unlockAudio:function(){var n=this||e||t;if(!n._audioUnlocked&&n.ctx){n._audioUnlocked=false;n.autoUnlock=false;if(!n._mobileUnloaded&&44100!==n.ctx.sampleRate){n._mobileUnloaded=true;n.unload()}n._scratchBuffer=n.ctx.createBuffer(1,1,22050);var unlock=function(e){while(n._html5AudioPool.length<n.html5PoolSize)try{var t=new Audio;t._unlocked=true;n._releaseHtml5Audio(t)}catch(e){n.noAudio=true;break}for(var o=0;o<n._howls.length;o++)if(!n._howls[o]._webAudio){var r=n._howls[o]._getSoundIds();for(var a=0;a<r.length;a++){var i=n._howls[o]._soundById(r[a]);if(i&&i._node&&!i._node._unlocked){i._node._unlocked=true;i._node.load()}}}n._autoResume();var u=n.ctx.createBufferSource();u.buffer=n._scratchBuffer;u.connect(n.ctx.destination);"undefined"===typeof u.start?u.noteOn(0):u.start(0);"function"===typeof n.ctx.resume&&n.ctx.resume();u.onended=function(){u.disconnect(0);n._audioUnlocked=true;document.removeEventListener("touchstart",unlock,true);document.removeEventListener("touchend",unlock,true);document.removeEventListener("click",unlock,true);document.removeEventListener("keydown",unlock,true);for(var e=0;e<n._howls.length;e++)n._howls[e]._emit("unlock")}};document.addEventListener("touchstart",unlock,true);document.addEventListener("touchend",unlock,true);document.addEventListener("click",unlock,true);document.addEventListener("keydown",unlock,true);return n}},_obtainHtml5Audio:function(){var n=this||e||t;if(n._html5AudioPool.length)return n._html5AudioPool.pop();var o=(new Audio).play();o&&"undefined"!==typeof Promise&&(o instanceof Promise||"function"===typeof o.then)&&o.catch((function(){console.warn("HTML5 Audio pool exhausted, returning potentially locked audio object.")}));return new Audio},_releaseHtml5Audio:function(n){var o=this||e||t;n._unlocked&&o._html5AudioPool.push(n);return o},_autoSuspend:function(){var n=this||e;if(n.autoSuspend&&n.ctx&&"undefined"!==typeof n.ctx.suspend&&t.usingWebAudio){for(var o=0;o<n._howls.length;o++)if(n._howls[o]._webAudio)for(var r=0;r<n._howls[o]._sounds.length;r++)if(!n._howls[o]._sounds[r]._paused)return n;n._suspendTimer&&clearTimeout(n._suspendTimer);n._suspendTimer=setTimeout((function(){if(n.autoSuspend){n._suspendTimer=null;n.state="suspending";var handleSuspension=function(){n.state="suspended";if(n._resumeAfterSuspend){delete n._resumeAfterSuspend;n._autoResume()}};n.ctx.suspend().then(handleSuspension,handleSuspension)}}),3e4);return n}},_autoResume:function(){var n=this||e;if(n.ctx&&"undefined"!==typeof n.ctx.resume&&t.usingWebAudio){if("running"===n.state&&"interrupted"!==n.ctx.state&&n._suspendTimer){clearTimeout(n._suspendTimer);n._suspendTimer=null}else if("suspended"===n.state||"running"===n.state&&"interrupted"===n.ctx.state){n.ctx.resume().then((function(){n.state="running";for(var e=0;e<n._howls.length;e++)n._howls[e]._emit("resume")}));if(n._suspendTimer){clearTimeout(n._suspendTimer);n._suspendTimer=null}}else"suspending"===n.state&&(n._resumeAfterSuspend=true);return n}}};var t=new HowlerGlobal;
/**
   * Create an audio group controller.
   * @param {Object} o Passed in properties for this group.
   */var Howl=function(n){var t=this||e;n.src&&0!==n.src.length?t.init(n):console.error("An array of source files must be passed with any new Howl.")};Howl.prototype={
/**
     * Initialize a new Howl group object.
     * @param  {Object} o Passed in properties for this group.
     * @return {Howl}
     */
init:function(n){var o=this||e;t.ctx||setupAudioContext();o._autoplay=n.autoplay||false;o._format="string"!==typeof n.format?n.format:[n.format];o._html5=n.html5||false;o._muted=n.mute||false;o._loop=n.loop||false;o._pool=n.pool||5;o._preload="boolean"!==typeof n.preload&&"metadata"!==n.preload||n.preload;o._rate=n.rate||1;o._sprite=n.sprite||{};o._src="string"!==typeof n.src?n.src:[n.src];o._volume=void 0!==n.volume?n.volume:1;o._xhr={method:n.xhr&&n.xhr.method?n.xhr.method:"GET",headers:n.xhr&&n.xhr.headers?n.xhr.headers:null,withCredentials:!(!n.xhr||!n.xhr.withCredentials)&&n.xhr.withCredentials};o._duration=0;o._state="unloaded";o._sounds=[];o._endTimers={};o._queue=[];o._playLock=false;o._onend=n.onend?[{fn:n.onend}]:[];o._onfade=n.onfade?[{fn:n.onfade}]:[];o._onload=n.onload?[{fn:n.onload}]:[];o._onloaderror=n.onloaderror?[{fn:n.onloaderror}]:[];o._onplayerror=n.onplayerror?[{fn:n.onplayerror}]:[];o._onpause=n.onpause?[{fn:n.onpause}]:[];o._onplay=n.onplay?[{fn:n.onplay}]:[];o._onstop=n.onstop?[{fn:n.onstop}]:[];o._onmute=n.onmute?[{fn:n.onmute}]:[];o._onvolume=n.onvolume?[{fn:n.onvolume}]:[];o._onrate=n.onrate?[{fn:n.onrate}]:[];o._onseek=n.onseek?[{fn:n.onseek}]:[];o._onunlock=n.onunlock?[{fn:n.onunlock}]:[];o._onresume=[];o._webAudio=t.usingWebAudio&&!o._html5;"undefined"!==typeof t.ctx&&t.ctx&&t.autoUnlock&&t._unlockAudio();t._howls.push(o);o._autoplay&&o._queue.push({event:"play",action:function(){o.play()}});o._preload&&"none"!==o._preload&&o.load();return o},load:function(){var n=this||e;var o=null;if(t.noAudio)n._emit("loaderror",null,"No audio support.");else{"string"===typeof n._src&&(n._src=[n._src]);for(var r=0;r<n._src.length;r++){var a,i;if(n._format&&n._format[r])a=n._format[r];else{i=n._src[r];if("string"!==typeof i){n._emit("loaderror",null,"Non-string found in selected audio sources - ignoring.");continue}a=/^data:audio\/([^;,]+);/i.exec(i);a||(a=/\.([^.]+)$/.exec(i.split("?",1)[0]));a&&(a=a[1].toLowerCase())}a||console.warn('No file extension was found. Consider using the "format" property or specify an extension.');if(a&&t.codecs(a)){o=n._src[r];break}}if(o){n._src=o;n._state="loading";if("https:"===window.location.protocol&&"http:"===o.slice(0,5)){n._html5=true;n._webAudio=false}new Sound(n);n._webAudio&&loadBuffer(n);return n}n._emit("loaderror",null,"No codec support for selected audio sources.")}},
/**
     * Play a sound or resume previous playback.
     * @param  {String/Number} sprite   Sprite name for sprite playback or sound id to continue previous.
     * @param  {Boolean} internal Internal Use: true prevents event firing.
     * @return {Number}          Sound ID.
     */
play:function(n,o){var r=this||e;var a=null;if("number"===typeof n){a=n;n=null}else{if("string"===typeof n&&"loaded"===r._state&&!r._sprite[n])return null;if("undefined"===typeof n){n="__default";if(!r._playLock){var i=0;for(var u=0;u<r._sounds.length;u++)if(r._sounds[u]._paused&&!r._sounds[u]._ended){i++;a=r._sounds[u]._id}1===i?n=null:a=null}}}var d=a?r._soundById(a):r._inactiveSound();if(!d)return null;a&&!n&&(n=d._sprite||"__default");if("loaded"!==r._state){d._sprite=n;d._ended=false;var s=d._id;r._queue.push({event:"play",action:function(){r.play(s)}});return s}if(a&&!d._paused){o||r._loadQueue("play");return d._id}r._webAudio&&t._autoResume();var _=Math.max(0,d._seek>0?d._seek:r._sprite[n][0]/1e3);var l=Math.max(0,(r._sprite[n][0]+r._sprite[n][1])/1e3-_);var f=1e3*l/Math.abs(d._rate);var c=r._sprite[n][0]/1e3;var p=(r._sprite[n][0]+r._sprite[n][1])/1e3;d._sprite=n;d._ended=false;var setParams=function(){d._paused=false;d._seek=_;d._start=c;d._stop=p;d._loop=!!(d._loop||r._sprite[n][2])};if(!(_>=p)){var m=d._node;if(r._webAudio){var playWebAudio=function(){r._playLock=false;setParams();r._refreshBuffer(d);var e=d._muted||r._muted?0:d._volume;m.gain.setValueAtTime(e,t.ctx.currentTime);d._playStart=t.ctx.currentTime;"undefined"===typeof m.bufferSource.start?d._loop?m.bufferSource.noteGrainOn(0,_,86400):m.bufferSource.noteGrainOn(0,_,l):d._loop?m.bufferSource.start(0,_,86400):m.bufferSource.start(0,_,l);Infinity!==f&&(r._endTimers[d._id]=setTimeout(r._ended.bind(r,d),f));o||setTimeout((function(){r._emit("play",d._id);r._loadQueue()}),0)};if("running"===t.state&&"interrupted"!==t.ctx.state)playWebAudio();else{r._playLock=true;r.once("resume",playWebAudio);r._clearTimer(d._id)}}else{var playHtml5=function(){m.currentTime=_;m.muted=d._muted||r._muted||t._muted||m.muted;m.volume=d._volume*t.volume();m.playbackRate=d._rate;try{var e=m.play();if(e&&"undefined"!==typeof Promise&&(e instanceof Promise||"function"===typeof e.then)){r._playLock=true;setParams();e.then((function(){r._playLock=false;m._unlocked=true;o?r._loadQueue():r._emit("play",d._id)})).catch((function(){r._playLock=false;r._emit("playerror",d._id,"Playback was unable to start. This is most commonly an issue on mobile devices and Chrome where playback was not within a user interaction.");d._ended=true;d._paused=true}))}else if(!o){r._playLock=false;setParams();r._emit("play",d._id)}m.playbackRate=d._rate;if(m.paused){r._emit("playerror",d._id,"Playback was unable to start. This is most commonly an issue on mobile devices and Chrome where playback was not within a user interaction.");return}if("__default"!==n||d._loop)r._endTimers[d._id]=setTimeout(r._ended.bind(r,d),f);else{r._endTimers[d._id]=function(){r._ended(d);m.removeEventListener("ended",r._endTimers[d._id],false)};m.addEventListener("ended",r._endTimers[d._id],false)}}catch(e){r._emit("playerror",d._id,e)}};if("data:audio/wav;base64,UklGRigAAABXQVZFZm10IBIAAAABAAEARKwAAIhYAQACABAAAABkYXRhAgAAAAEA"===m.src){m.src=r._src;m.load()}var v=window&&window.ejecta||!m.readyState&&t._navigator.isCocoonJS;if(m.readyState>=3||v)playHtml5();else{r._playLock=true;r._state="loading";var listener=function(){r._state="loaded";playHtml5();m.removeEventListener(t._canPlayEvent,listener,false)};m.addEventListener(t._canPlayEvent,listener,false);r._clearTimer(d._id)}}return d._id}r._ended(d)},
/**
     * Pause playback and save current position.
     * @param  {Number} id The sound ID (empty to pause all in group).
     * @return {Howl}
     */
pause:function(n){var t=this||e;if("loaded"!==t._state||t._playLock){t._queue.push({event:"pause",action:function(){t.pause(n)}});return t}var o=t._getSoundIds(n);for(var r=0;r<o.length;r++){t._clearTimer(o[r]);var a=t._soundById(o[r]);if(a&&!a._paused){a._seek=t.seek(o[r]);a._rateSeek=0;a._paused=true;t._stopFade(o[r]);if(a._node)if(t._webAudio){if(!a._node.bufferSource)continue;"undefined"===typeof a._node.bufferSource.stop?a._node.bufferSource.noteOff(0):a._node.bufferSource.stop(0);t._cleanBuffer(a._node)}else isNaN(a._node.duration)&&Infinity!==a._node.duration||a._node.pause()}arguments[1]||t._emit("pause",a?a._id:null)}return t},
/**
     * Stop playback and reset to start.
     * @param  {Number} id The sound ID (empty to stop all in group).
     * @param  {Boolean} internal Internal Use: true prevents event firing.
     * @return {Howl}
     */
stop:function(n,t){var o=this||e;if("loaded"!==o._state||o._playLock){o._queue.push({event:"stop",action:function(){o.stop(n)}});return o}var r=o._getSoundIds(n);for(var a=0;a<r.length;a++){o._clearTimer(r[a]);var i=o._soundById(r[a]);if(i){i._seek=i._start||0;i._rateSeek=0;i._paused=true;i._ended=true;o._stopFade(r[a]);if(i._node)if(o._webAudio){if(i._node.bufferSource){"undefined"===typeof i._node.bufferSource.stop?i._node.bufferSource.noteOff(0):i._node.bufferSource.stop(0);o._cleanBuffer(i._node)}}else if(!isNaN(i._node.duration)||Infinity===i._node.duration){i._node.currentTime=i._start||0;i._node.pause();Infinity===i._node.duration&&o._clearSound(i._node)}t||o._emit("stop",i._id)}}return o},
/**
     * Mute/unmute a single sound or all sounds in this Howl group.
     * @param  {Boolean} muted Set to true to mute and false to unmute.
     * @param  {Number} id    The sound ID to update (omit to mute/unmute all).
     * @return {Howl}
     */
mute:function(n,o){var r=this||e;if("loaded"!==r._state||r._playLock){r._queue.push({event:"mute",action:function(){r.mute(n,o)}});return r}if("undefined"===typeof o){if("boolean"!==typeof n)return r._muted;r._muted=n}var a=r._getSoundIds(o);for(var i=0;i<a.length;i++){var u=r._soundById(a[i]);if(u){u._muted=n;u._interval&&r._stopFade(u._id);r._webAudio&&u._node?u._node.gain.setValueAtTime(n?0:u._volume,t.ctx.currentTime):u._node&&(u._node.muted=!!t._muted||n);r._emit("mute",u._id)}}return r},volume:function(){var n=this||e;var o=arguments;var r,a;if(0===o.length)return n._volume;if(1===o.length||2===o.length&&"undefined"===typeof o[1]){var i=n._getSoundIds();var u=i.indexOf(o[0]);u>=0?a=parseInt(o[0],10):r=parseFloat(o[0])}else if(o.length>=2){r=parseFloat(o[0]);a=parseInt(o[1],10)}var d;if(!("undefined"!==typeof r&&r>=0&&r<=1)){d=a?n._soundById(a):n._sounds[0];return d?d._volume:0}if("loaded"!==n._state||n._playLock){n._queue.push({event:"volume",action:function(){n.volume.apply(n,o)}});return n}"undefined"===typeof a&&(n._volume=r);a=n._getSoundIds(a);for(var s=0;s<a.length;s++){d=n._soundById(a[s]);if(d){d._volume=r;o[2]||n._stopFade(a[s]);n._webAudio&&d._node&&!d._muted?d._node.gain.setValueAtTime(r,t.ctx.currentTime):d._node&&!d._muted&&(d._node.volume=r*t.volume());n._emit("volume",d._id)}}return n},
/**
     * Fade a currently playing sound between two volumes (if no id is passed, all sounds will fade).
     * @param  {Number} from The value to fade from (0.0 to 1.0).
     * @param  {Number} to   The volume to fade to (0.0 to 1.0).
     * @param  {Number} len  Time in milliseconds to fade.
     * @param  {Number} id   The sound id (omit to fade all sounds).
     * @return {Howl}
     */
fade:function(n,o,r,a){var i=this||e;if("loaded"!==i._state||i._playLock){i._queue.push({event:"fade",action:function(){i.fade(n,o,r,a)}});return i}n=Math.min(Math.max(0,parseFloat(n)),1);o=Math.min(Math.max(0,parseFloat(o)),1);r=parseFloat(r);i.volume(n,a);var u=i._getSoundIds(a);for(var d=0;d<u.length;d++){var s=i._soundById(u[d]);if(s){a||i._stopFade(u[d]);if(i._webAudio&&!s._muted){var _=t.ctx.currentTime;var l=_+r/1e3;s._volume=n;s._node.gain.setValueAtTime(n,_);s._node.gain.linearRampToValueAtTime(o,l)}i._startFadeInterval(s,n,o,r,u[d],"undefined"===typeof a)}}return i},
/**
     * Starts the internal interval to fade a sound.
     * @param  {Object} sound Reference to sound to fade.
     * @param  {Number} from The value to fade from (0.0 to 1.0).
     * @param  {Number} to   The volume to fade to (0.0 to 1.0).
     * @param  {Number} len  Time in milliseconds to fade.
     * @param  {Number} id   The sound id to fade.
     * @param  {Boolean} isGroup   If true, set the volume on the group.
     */
_startFadeInterval:function(n,t,o,r,a,i){var u=this||e;var d=t;var s=o-t;var _=Math.abs(s/.01);var l=Math.max(4,_>0?r/_:r);var f=Date.now();n._fadeTo=o;n._interval=setInterval((function(){var e=(Date.now()-f)/r;f=Date.now();d+=s*e;d=Math.round(100*d)/100;d=s<0?Math.max(o,d):Math.min(o,d);u._webAudio?n._volume=d:u.volume(d,n._id,true);i&&(u._volume=d);if(o<t&&d<=o||o>t&&d>=o){clearInterval(n._interval);n._interval=null;n._fadeTo=null;u.volume(o,n._id);u._emit("fade",n._id)}}),l)},
/**
     * Internal method that stops the currently playing fade when
     * a new fade starts, volume is changed or the sound is stopped.
     * @param  {Number} id The sound id.
     * @return {Howl}
     */
_stopFade:function(n){var o=this||e;var r=o._soundById(n);if(r&&r._interval){o._webAudio&&r._node.gain.cancelScheduledValues(t.ctx.currentTime);clearInterval(r._interval);r._interval=null;o.volume(r._fadeTo,n);r._fadeTo=null;o._emit("fade",n)}return o},loop:function(){var n=this||e;var t=arguments;var o,r,a;if(0===t.length)return n._loop;if(1===t.length){if("boolean"!==typeof t[0]){a=n._soundById(parseInt(t[0],10));return!!a&&a._loop}o=t[0];n._loop=o}else if(2===t.length){o=t[0];r=parseInt(t[1],10)}var i=n._getSoundIds(r);for(var u=0;u<i.length;u++){a=n._soundById(i[u]);if(a){a._loop=o;if(n._webAudio&&a._node&&a._node.bufferSource){a._node.bufferSource.loop=o;if(o){a._node.bufferSource.loopStart=a._start||0;a._node.bufferSource.loopEnd=a._stop;if(n.playing(i[u])){n.pause(i[u],true);n.play(i[u],true)}}}}}return n},rate:function(){var n=this||e;var o=arguments;var r,a;if(0===o.length)a=n._sounds[0]._id;else if(1===o.length){var i=n._getSoundIds();var u=i.indexOf(o[0]);u>=0?a=parseInt(o[0],10):r=parseFloat(o[0])}else if(2===o.length){r=parseFloat(o[0]);a=parseInt(o[1],10)}var d;if("number"!==typeof r){d=n._soundById(a);return d?d._rate:n._rate}if("loaded"!==n._state||n._playLock){n._queue.push({event:"rate",action:function(){n.rate.apply(n,o)}});return n}"undefined"===typeof a&&(n._rate=r);a=n._getSoundIds(a);for(var s=0;s<a.length;s++){d=n._soundById(a[s]);if(d){if(n.playing(a[s])){d._rateSeek=n.seek(a[s]);d._playStart=n._webAudio?t.ctx.currentTime:d._playStart}d._rate=r;n._webAudio&&d._node&&d._node.bufferSource?d._node.bufferSource.playbackRate.setValueAtTime(r,t.ctx.currentTime):d._node&&(d._node.playbackRate=r);var _=n.seek(a[s]);var l=(n._sprite[d._sprite][0]+n._sprite[d._sprite][1])/1e3-_;var f=1e3*l/Math.abs(d._rate);if(n._endTimers[a[s]]||!d._paused){n._clearTimer(a[s]);n._endTimers[a[s]]=setTimeout(n._ended.bind(n,d),f)}n._emit("rate",d._id)}}return n},seek:function(){var n=this||e;var o=arguments;var r,a;if(0===o.length)n._sounds.length&&(a=n._sounds[0]._id);else if(1===o.length){var i=n._getSoundIds();var u=i.indexOf(o[0]);if(u>=0)a=parseInt(o[0],10);else if(n._sounds.length){a=n._sounds[0]._id;r=parseFloat(o[0])}}else if(2===o.length){r=parseFloat(o[0]);a=parseInt(o[1],10)}if("undefined"===typeof a)return 0;if("number"===typeof r&&("loaded"!==n._state||n._playLock)){n._queue.push({event:"seek",action:function(){n.seek.apply(n,o)}});return n}var d=n._soundById(a);if(d){if(!("number"===typeof r&&r>=0)){if(n._webAudio){var s=n.playing(a)?t.ctx.currentTime-d._playStart:0;var _=d._rateSeek?d._rateSeek-d._seek:0;return d._seek+(_+s*Math.abs(d._rate))}return d._node.currentTime}var l=n.playing(a);l&&n.pause(a,true);d._seek=r;d._ended=false;n._clearTimer(a);n._webAudio||!d._node||isNaN(d._node.duration)||(d._node.currentTime=r);var seekAndEmit=function(){l&&n.play(a,true);n._emit("seek",a)};if(l&&!n._webAudio){var emitSeek=function(){n._playLock?setTimeout(emitSeek,0):seekAndEmit()};setTimeout(emitSeek,0)}else seekAndEmit()}return n},
/**
     * Check if a specific sound is currently playing or not (if id is provided), or check if at least one of the sounds in the group is playing or not.
     * @param  {Number}  id The sound id to check. If none is passed, the whole sound group is checked.
     * @return {Boolean} True if playing and false if not.
     */
playing:function(n){var t=this||e;if("number"===typeof n){var o=t._soundById(n);return!!o&&!o._paused}for(var r=0;r<t._sounds.length;r++)if(!t._sounds[r]._paused)return true;return false},
/**
     * Get the duration of this sound. Passing a sound id will return the sprite duration.
     * @param  {Number} id The sound id to check. If none is passed, return full source duration.
     * @return {Number} Audio duration in seconds.
     */
duration:function(n){var t=this||e;var o=t._duration;var r=t._soundById(n);r&&(o=t._sprite[r._sprite][1]/1e3);return o},state:function(){return(this||e)._state},unload:function(){var n=this||e;var r=n._sounds;for(var a=0;a<r.length;a++){r[a]._paused||n.stop(r[a]._id);if(!n._webAudio){n._clearSound(r[a]._node);r[a]._node.removeEventListener("error",r[a]._errorFn,false);r[a]._node.removeEventListener(t._canPlayEvent,r[a]._loadFn,false);r[a]._node.removeEventListener("ended",r[a]._endFn,false);t._releaseHtml5Audio(r[a]._node)}delete r[a]._node;n._clearTimer(r[a]._id)}var i=t._howls.indexOf(n);i>=0&&t._howls.splice(i,1);var u=true;for(a=0;a<t._howls.length;a++)if(t._howls[a]._src===n._src||n._src.indexOf(t._howls[a]._src)>=0){u=false;break}o&&u&&delete o[n._src];t.noAudio=false;n._state="unloaded";n._sounds=[];n=null;return null},
/**
     * Listen to a custom event.
     * @param  {String}   event Event name.
     * @param  {Function} fn    Listener to call.
     * @param  {Number}   id    (optional) Only listen to events for this sound.
     * @param  {Number}   once  (INTERNAL) Marks event to fire only once.
     * @return {Howl}
     */
on:function(n,t,o,r){var a=this||e;var i=a["_on"+n];"function"===typeof t&&i.push(r?{id:o,fn:t,once:r}:{id:o,fn:t});return a},
/**
     * Remove a custom event. Call without parameters to remove all events.
     * @param  {String}   event Event name.
     * @param  {Function} fn    Listener to remove. Leave empty to remove all.
     * @param  {Number}   id    (optional) Only remove events for this sound.
     * @return {Howl}
     */
off:function(n,t,o){var r=this||e;var a=r["_on"+n];var i=0;if("number"===typeof t){o=t;t=null}if(t||o)for(i=0;i<a.length;i++){var u=o===a[i].id;if(t===a[i].fn&&u||!t&&u){a.splice(i,1);break}}else if(n)r["_on"+n]=[];else{var d=Object.keys(r);for(i=0;i<d.length;i++)0===d[i].indexOf("_on")&&Array.isArray(r[d[i]])&&(r[d[i]]=[])}return r},
/**
     * Listen to a custom event and remove it once fired.
     * @param  {String}   event Event name.
     * @param  {Function} fn    Listener to call.
     * @param  {Number}   id    (optional) Only listen to events for this sound.
     * @return {Howl}
     */
once:function(n,t,o){var r=this||e;r.on(n,t,o,1);return r},
/**
     * Emit all events of a specific type and pass the sound id.
     * @param  {String} event Event name.
     * @param  {Number} id    Sound ID.
     * @param  {Number} msg   Message to go with event.
     * @return {Howl}
     */
_emit:function(n,t,o){var r=this||e;var a=r["_on"+n];for(var i=a.length-1;i>=0;i--)if(!a[i].id||a[i].id===t||"load"===n){setTimeout(function(n){n.call(this||e,t,o)}.bind(r,a[i].fn),0);a[i].once&&r.off(n,a[i].fn,a[i].id)}r._loadQueue(n);return r},_loadQueue:function(n){var t=this||e;if(t._queue.length>0){var o=t._queue[0];if(o.event===n){t._queue.shift();t._loadQueue()}n||o.action()}return t},
/**
     * Fired when playback ends at the end of the duration.
     * @param  {Sound} sound The sound object to work with.
     * @return {Howl}
     */
_ended:function(n){var o=this||e;var r=n._sprite;if(!o._webAudio&&n._node&&!n._node.paused&&!n._node.ended&&n._node.currentTime<n._stop){setTimeout(o._ended.bind(o,n),100);return o}var a=!!(n._loop||o._sprite[r][2]);o._emit("end",n._id);!o._webAudio&&a&&o.stop(n._id,true).play(n._id);if(o._webAudio&&a){o._emit("play",n._id);n._seek=n._start||0;n._rateSeek=0;n._playStart=t.ctx.currentTime;var i=1e3*(n._stop-n._start)/Math.abs(n._rate);o._endTimers[n._id]=setTimeout(o._ended.bind(o,n),i)}if(o._webAudio&&!a){n._paused=true;n._ended=true;n._seek=n._start||0;n._rateSeek=0;o._clearTimer(n._id);o._cleanBuffer(n._node);t._autoSuspend()}o._webAudio||a||o.stop(n._id,true);return o},
/**
     * Clear the end timer for a sound playback.
     * @param  {Number} id The sound ID.
     * @return {Howl}
     */
_clearTimer:function(n){var t=this||e;if(t._endTimers[n]){if("function"!==typeof t._endTimers[n])clearTimeout(t._endTimers[n]);else{var o=t._soundById(n);o&&o._node&&o._node.removeEventListener("ended",t._endTimers[n],false)}delete t._endTimers[n]}return t},
/**
     * Return the sound identified by this ID, or return null.
     * @param  {Number} id Sound ID
     * @return {Object}    Sound object or null.
     */
_soundById:function(n){var t=this||e;for(var o=0;o<t._sounds.length;o++)if(n===t._sounds[o]._id)return t._sounds[o];return null},_inactiveSound:function(){var n=this||e;n._drain();for(var t=0;t<n._sounds.length;t++)if(n._sounds[t]._ended)return n._sounds[t].reset();return new Sound(n)},_drain:function(){var n=this||e;var t=n._pool;var o=0;var r=0;if(!(n._sounds.length<t)){for(r=0;r<n._sounds.length;r++)n._sounds[r]._ended&&o++;for(r=n._sounds.length-1;r>=0;r--){if(o<=t)return;if(n._sounds[r]._ended){n._webAudio&&n._sounds[r]._node&&n._sounds[r]._node.disconnect(0);n._sounds.splice(r,1);o--}}}},
/**
     * Get all ID's from the sounds pool.
     * @param  {Number} id Only return one ID if one is passed.
     * @return {Array}    Array of IDs.
     */
_getSoundIds:function(n){var t=this||e;if("undefined"===typeof n){var o=[];for(var r=0;r<t._sounds.length;r++)o.push(t._sounds[r]._id);return o}return[n]},
/**
     * Load the sound back into the buffer source.
     * @param  {Sound} sound The sound object to work with.
     * @return {Howl}
     */
_refreshBuffer:function(n){var r=this||e;n._node.bufferSource=t.ctx.createBufferSource();n._node.bufferSource.buffer=o[r._src];n._panner?n._node.bufferSource.connect(n._panner):n._node.bufferSource.connect(n._node);n._node.bufferSource.loop=n._loop;if(n._loop){n._node.bufferSource.loopStart=n._start||0;n._node.bufferSource.loopEnd=n._stop||0}n._node.bufferSource.playbackRate.setValueAtTime(n._rate,t.ctx.currentTime);return r},
/**
     * Prevent memory leaks by cleaning up the buffer source after playback.
     * @param  {Object} node Sound's audio node containing the buffer source.
     * @return {Howl}
     */
_cleanBuffer:function(n){var o=this||e;var r=t._navigator&&t._navigator.vendor.indexOf("Apple")>=0;if(t._scratchBuffer&&n.bufferSource){n.bufferSource.onended=null;n.bufferSource.disconnect(0);if(r)try{n.bufferSource.buffer=t._scratchBuffer}catch(e){}}n.bufferSource=null;return o},
/**
     * Set the source to a 0-second silence to stop any downloading (except in IE).
     * @param  {Object} node Audio node to clear.
     */
_clearSound:function(e){var n=/MSIE |Trident\//.test(t._navigator&&t._navigator.userAgent);n||(e.src="data:audio/wav;base64,UklGRigAAABXQVZFZm10IBIAAAABAAEARKwAAIhYAQACABAAAABkYXRhAgAAAAEA")}};
/**
   * Setup the sound object, which each node attached to a Howl group is contained in.
   * @param {Object} howl The Howl parent group.
   */var Sound=function(n){(this||e)._parent=n;this.init()};Sound.prototype={init:function(){var n=this||e;var o=n._parent;n._muted=o._muted;n._loop=o._loop;n._volume=o._volume;n._rate=o._rate;n._seek=0;n._paused=true;n._ended=true;n._sprite="__default";n._id=++t._counter;o._sounds.push(n);n.create();return n},create:function(){var n=this||e;var o=n._parent;var r=t._muted||n._muted||n._parent._muted?0:n._volume;if(o._webAudio){n._node="undefined"===typeof t.ctx.createGain?t.ctx.createGainNode():t.ctx.createGain();n._node.gain.setValueAtTime(r,t.ctx.currentTime);n._node.paused=true;n._node.connect(t.masterGain)}else if(!t.noAudio){n._node=t._obtainHtml5Audio();n._errorFn=n._errorListener.bind(n);n._node.addEventListener("error",n._errorFn,false);n._loadFn=n._loadListener.bind(n);n._node.addEventListener(t._canPlayEvent,n._loadFn,false);n._endFn=n._endListener.bind(n);n._node.addEventListener("ended",n._endFn,false);n._node.src=o._src;n._node.preload=true===o._preload?"auto":o._preload;n._node.volume=r*t.volume();n._node.load()}return n},reset:function(){var n=this||e;var o=n._parent;n._muted=o._muted;n._loop=o._loop;n._volume=o._volume;n._rate=o._rate;n._seek=0;n._rateSeek=0;n._paused=true;n._ended=true;n._sprite="__default";n._id=++t._counter;return n},_errorListener:function(){var n=this||e;n._parent._emit("loaderror",n._id,n._node.error?n._node.error.code:0);n._node.removeEventListener("error",n._errorFn,false)},_loadListener:function(){var n=this||e;var o=n._parent;o._duration=Math.ceil(10*n._node.duration)/10;0===Object.keys(o._sprite).length&&(o._sprite={__default:[0,1e3*o._duration]});if("loaded"!==o._state){o._state="loaded";o._emit("load");o._loadQueue()}n._node.removeEventListener(t._canPlayEvent,n._loadFn,false)},_endListener:function(){var n=this||e;var t=n._parent;if(Infinity===t._duration){t._duration=Math.ceil(10*n._node.duration)/10;Infinity===t._sprite.__default[1]&&(t._sprite.__default[1]=1e3*t._duration);t._ended(n)}n._node.removeEventListener("ended",n._endFn,false)}};var o={};
/**
   * Buffer a sound from URL, Data URI or cache and decode to audio source (Web Audio API).
   * @param  {Howl} self
   */var loadBuffer=function(e){var n=e._src;if(o[n]){e._duration=o[n].duration;loadSound(e)}else if(/^data:[^;]+;base64,/.test(n)){var t=atob(n.split(",")[1]);var r=new Uint8Array(t.length);for(var a=0;a<t.length;++a)r[a]=t.charCodeAt(a);decodeAudioData(r.buffer,e)}else{var i=new XMLHttpRequest;i.open(e._xhr.method,n,true);i.withCredentials=e._xhr.withCredentials;i.responseType="arraybuffer";e._xhr.headers&&Object.keys(e._xhr.headers).forEach((function(n){i.setRequestHeader(n,e._xhr.headers[n])}));i.onload=function(){var n=(i.status+"")[0];"0"===n||"2"===n||"3"===n?decodeAudioData(i.response,e):e._emit("loaderror",null,"Failed loading audio file with status: "+i.status+".")};i.onerror=function(){if(e._webAudio){e._html5=true;e._webAudio=false;e._sounds=[];delete o[n];e.load()}};safeXhrSend(i)}};
/**
   * Send the XHR request wrapped in a try/catch.
   * @param  {Object} xhr XHR to send.
   */var safeXhrSend=function(e){try{e.send()}catch(n){e.onerror()}};
/**
   * Decode audio data from an array buffer.
   * @param  {ArrayBuffer} arraybuffer The audio data.
   * @param  {Howl}        self
   */var decodeAudioData=function(e,n){var error=function(){n._emit("loaderror",null,"Decoding audio data failed.")};var success=function(e){if(e&&n._sounds.length>0){o[n._src]=e;loadSound(n,e)}else error()};"undefined"!==typeof Promise&&1===t.ctx.decodeAudioData.length?t.ctx.decodeAudioData(e).then(success).catch(error):t.ctx.decodeAudioData(e,success,error)};
/**
   * Sound is now loaded, so finish setting everything up and fire the loaded event.
   * @param  {Howl} self
   * @param  {Object} buffer The decoded buffer sound source.
   */var loadSound=function(e,n){n&&!e._duration&&(e._duration=n.duration);0===Object.keys(e._sprite).length&&(e._sprite={__default:[0,1e3*e._duration]});if("loaded"!==e._state){e._state="loaded";e._emit("load");e._loadQueue()}};var setupAudioContext=function(){if(t.usingWebAudio){try{"undefined"!==typeof AudioContext?t.ctx=new AudioContext:"undefined"!==typeof webkitAudioContext?t.ctx=new webkitAudioContext:t.usingWebAudio=false}catch(e){t.usingWebAudio=false}t.ctx||(t.usingWebAudio=false);var e=/iP(hone|od|ad)/.test(t._navigator&&t._navigator.platform);var n=t._navigator&&t._navigator.appVersion.match(/OS (\d+)_(\d+)_?(\d+)?/);var o=n?parseInt(n[1],10):null;if(e&&o&&o<9){var r=/safari/.test(t._navigator&&t._navigator.userAgent.toLowerCase());t._navigator&&!r&&(t.usingWebAudio=false)}if(t.usingWebAudio){t.masterGain="undefined"===typeof t.ctx.createGain?t.ctx.createGainNode():t.ctx.createGain();t.masterGain.gain.setValueAtTime(t._muted?0:t._volume,t.ctx.currentTime);t.masterGain.connect(t.ctx.destination)}t._setup()}};n.Howler=t;n.Howl=Howl;if("undefined"!==typeof e){e.HowlerGlobal=HowlerGlobal;e.Howler=t;e.Howl=Howl;e.Sound=Sound}else if("undefined"!==typeof window){window.HowlerGlobal=HowlerGlobal;window.Howler=t;window.Howl=Howl;window.Sound=Sound}})();(function(){HowlerGlobal.prototype._pos=[0,0,0];HowlerGlobal.prototype._orientation=[0,0,-1,0,1,0];
/**
   * Helper method to update the stereo panning position of all current Howls.
   * Future Howls will not use this value unless explicitly set.
   * @param  {Number} pan A value of -1.0 is all the way left and 1.0 is all the way right.
   * @return {Howler/Number}     Self or current stereo panning value.
   */HowlerGlobal.prototype.stereo=function(n){var t=this||e;if(!t.ctx||!t.ctx.listener)return t;for(var o=t._howls.length-1;o>=0;o--)t._howls[o].stereo(n);return t};
/**
   * Get/set the position of the listener in 3D cartesian space. Sounds using
   * 3D position will be relative to the listener's position.
   * @param  {Number} x The x-position of the listener.
   * @param  {Number} y The y-position of the listener.
   * @param  {Number} z The z-position of the listener.
   * @return {Howler/Array}   Self or current listener position.
   */HowlerGlobal.prototype.pos=function(n,t,o){var r=this||e;if(!r.ctx||!r.ctx.listener)return r;t="number"!==typeof t?r._pos[1]:t;o="number"!==typeof o?r._pos[2]:o;if("number"!==typeof n)return r._pos;r._pos=[n,t,o];if("undefined"!==typeof r.ctx.listener.positionX){r.ctx.listener.positionX.setTargetAtTime(r._pos[0],Howler.ctx.currentTime,.1);r.ctx.listener.positionY.setTargetAtTime(r._pos[1],Howler.ctx.currentTime,.1);r.ctx.listener.positionZ.setTargetAtTime(r._pos[2],Howler.ctx.currentTime,.1)}else r.ctx.listener.setPosition(r._pos[0],r._pos[1],r._pos[2]);return r};
/**
   * Get/set the direction the listener is pointing in the 3D cartesian space.
   * A front and up vector must be provided. The front is the direction the
   * face of the listener is pointing, and up is the direction the top of the
   * listener is pointing. Thus, these values are expected to be at right angles
   * from each other.
   * @param  {Number} x   The x-orientation of the listener.
   * @param  {Number} y   The y-orientation of the listener.
   * @param  {Number} z   The z-orientation of the listener.
   * @param  {Number} xUp The x-orientation of the top of the listener.
   * @param  {Number} yUp The y-orientation of the top of the listener.
   * @param  {Number} zUp The z-orientation of the top of the listener.
   * @return {Howler/Array}     Returns self or the current orientation vectors.
   */HowlerGlobal.prototype.orientation=function(n,t,o,r,a,i){var u=this||e;if(!u.ctx||!u.ctx.listener)return u;var d=u._orientation;t="number"!==typeof t?d[1]:t;o="number"!==typeof o?d[2]:o;r="number"!==typeof r?d[3]:r;a="number"!==typeof a?d[4]:a;i="number"!==typeof i?d[5]:i;if("number"!==typeof n)return d;u._orientation=[n,t,o,r,a,i];if("undefined"!==typeof u.ctx.listener.forwardX){u.ctx.listener.forwardX.setTargetAtTime(n,Howler.ctx.currentTime,.1);u.ctx.listener.forwardY.setTargetAtTime(t,Howler.ctx.currentTime,.1);u.ctx.listener.forwardZ.setTargetAtTime(o,Howler.ctx.currentTime,.1);u.ctx.listener.upX.setTargetAtTime(r,Howler.ctx.currentTime,.1);u.ctx.listener.upY.setTargetAtTime(a,Howler.ctx.currentTime,.1);u.ctx.listener.upZ.setTargetAtTime(i,Howler.ctx.currentTime,.1)}else u.ctx.listener.setOrientation(n,t,o,r,a,i);return u};
/**
   * Add new properties to the core init.
   * @param  {Function} _super Core init method.
   * @return {Howl}
   */Howl.prototype.init=function(n){return function(t){var o=this||e;o._orientation=t.orientation||[1,0,0];o._stereo=t.stereo||null;o._pos=t.pos||null;o._pannerAttr={coneInnerAngle:"undefined"!==typeof t.coneInnerAngle?t.coneInnerAngle:360,coneOuterAngle:"undefined"!==typeof t.coneOuterAngle?t.coneOuterAngle:360,coneOuterGain:"undefined"!==typeof t.coneOuterGain?t.coneOuterGain:0,distanceModel:"undefined"!==typeof t.distanceModel?t.distanceModel:"inverse",maxDistance:"undefined"!==typeof t.maxDistance?t.maxDistance:1e4,panningModel:"undefined"!==typeof t.panningModel?t.panningModel:"HRTF",refDistance:"undefined"!==typeof t.refDistance?t.refDistance:1,rolloffFactor:"undefined"!==typeof t.rolloffFactor?t.rolloffFactor:1};o._onstereo=t.onstereo?[{fn:t.onstereo}]:[];o._onpos=t.onpos?[{fn:t.onpos}]:[];o._onorientation=t.onorientation?[{fn:t.onorientation}]:[];return n.call(this||e,t)}}(Howl.prototype.init);
/**
   * Get/set the stereo panning of the audio source for this sound or all in the group.
   * @param  {Number} pan  A value of -1.0 is all the way left and 1.0 is all the way right.
   * @param  {Number} id (optional) The sound ID. If none is passed, all in group will be updated.
   * @return {Howl/Number}    Returns self or the current stereo panning value.
   */Howl.prototype.stereo=function(n,t){var o=this||e;if(!o._webAudio)return o;if("loaded"!==o._state){o._queue.push({event:"stereo",action:function(){o.stereo(n,t)}});return o}var r="undefined"===typeof Howler.ctx.createStereoPanner?"spatial":"stereo";if("undefined"===typeof t){if("number"!==typeof n)return o._stereo;o._stereo=n;o._pos=[n,0,0]}var a=o._getSoundIds(t);for(var i=0;i<a.length;i++){var u=o._soundById(a[i]);if(u){if("number"!==typeof n)return u._stereo;u._stereo=n;u._pos=[n,0,0];if(u._node){u._pannerAttr.panningModel="equalpower";u._panner&&u._panner.pan||setupPanner(u,r);if("spatial"===r)if("undefined"!==typeof u._panner.positionX){u._panner.positionX.setValueAtTime(n,Howler.ctx.currentTime);u._panner.positionY.setValueAtTime(0,Howler.ctx.currentTime);u._panner.positionZ.setValueAtTime(0,Howler.ctx.currentTime)}else u._panner.setPosition(n,0,0);else u._panner.pan.setValueAtTime(n,Howler.ctx.currentTime)}o._emit("stereo",u._id)}}return o};
/**
   * Get/set the 3D spatial position of the audio source for this sound or group relative to the global listener.
   * @param  {Number} x  The x-position of the audio source.
   * @param  {Number} y  The y-position of the audio source.
   * @param  {Number} z  The z-position of the audio source.
   * @param  {Number} id (optional) The sound ID. If none is passed, all in group will be updated.
   * @return {Howl/Array}    Returns self or the current 3D spatial position: [x, y, z].
   */Howl.prototype.pos=function(n,t,o,r){var a=this||e;if(!a._webAudio)return a;if("loaded"!==a._state){a._queue.push({event:"pos",action:function(){a.pos(n,t,o,r)}});return a}t="number"!==typeof t?0:t;o="number"!==typeof o?-.5:o;if("undefined"===typeof r){if("number"!==typeof n)return a._pos;a._pos=[n,t,o]}var i=a._getSoundIds(r);for(var u=0;u<i.length;u++){var d=a._soundById(i[u]);if(d){if("number"!==typeof n)return d._pos;d._pos=[n,t,o];if(d._node){d._panner&&!d._panner.pan||setupPanner(d,"spatial");if("undefined"!==typeof d._panner.positionX){d._panner.positionX.setValueAtTime(n,Howler.ctx.currentTime);d._panner.positionY.setValueAtTime(t,Howler.ctx.currentTime);d._panner.positionZ.setValueAtTime(o,Howler.ctx.currentTime)}else d._panner.setPosition(n,t,o)}a._emit("pos",d._id)}}return a};
/**
   * Get/set the direction the audio source is pointing in the 3D cartesian coordinate
   * space. Depending on how direction the sound is, based on the `cone` attributes,
   * a sound pointing away from the listener can be quiet or silent.
   * @param  {Number} x  The x-orientation of the source.
   * @param  {Number} y  The y-orientation of the source.
   * @param  {Number} z  The z-orientation of the source.
   * @param  {Number} id (optional) The sound ID. If none is passed, all in group will be updated.
   * @return {Howl/Array}    Returns self or the current 3D spatial orientation: [x, y, z].
   */Howl.prototype.orientation=function(n,t,o,r){var a=this||e;if(!a._webAudio)return a;if("loaded"!==a._state){a._queue.push({event:"orientation",action:function(){a.orientation(n,t,o,r)}});return a}t="number"!==typeof t?a._orientation[1]:t;o="number"!==typeof o?a._orientation[2]:o;if("undefined"===typeof r){if("number"!==typeof n)return a._orientation;a._orientation=[n,t,o]}var i=a._getSoundIds(r);for(var u=0;u<i.length;u++){var d=a._soundById(i[u]);if(d){if("number"!==typeof n)return d._orientation;d._orientation=[n,t,o];if(d._node){if(!d._panner){d._pos||(d._pos=a._pos||[0,0,-.5]);setupPanner(d,"spatial")}if("undefined"!==typeof d._panner.orientationX){d._panner.orientationX.setValueAtTime(n,Howler.ctx.currentTime);d._panner.orientationY.setValueAtTime(t,Howler.ctx.currentTime);d._panner.orientationZ.setValueAtTime(o,Howler.ctx.currentTime)}else d._panner.setOrientation(n,t,o)}a._emit("orientation",d._id)}}return a};Howl.prototype.pannerAttr=function(){var n=this||e;var t=arguments;var o,r,a;if(!n._webAudio)return n;if(0===t.length)return n._pannerAttr;if(1===t.length){if("object"!==typeof t[0]){a=n._soundById(parseInt(t[0],10));return a?a._pannerAttr:n._pannerAttr}o=t[0];if("undefined"===typeof r){o.pannerAttr||(o.pannerAttr={coneInnerAngle:o.coneInnerAngle,coneOuterAngle:o.coneOuterAngle,coneOuterGain:o.coneOuterGain,distanceModel:o.distanceModel,maxDistance:o.maxDistance,refDistance:o.refDistance,rolloffFactor:o.rolloffFactor,panningModel:o.panningModel});n._pannerAttr={coneInnerAngle:"undefined"!==typeof o.pannerAttr.coneInnerAngle?o.pannerAttr.coneInnerAngle:n._coneInnerAngle,coneOuterAngle:"undefined"!==typeof o.pannerAttr.coneOuterAngle?o.pannerAttr.coneOuterAngle:n._coneOuterAngle,coneOuterGain:"undefined"!==typeof o.pannerAttr.coneOuterGain?o.pannerAttr.coneOuterGain:n._coneOuterGain,distanceModel:"undefined"!==typeof o.pannerAttr.distanceModel?o.pannerAttr.distanceModel:n._distanceModel,maxDistance:"undefined"!==typeof o.pannerAttr.maxDistance?o.pannerAttr.maxDistance:n._maxDistance,refDistance:"undefined"!==typeof o.pannerAttr.refDistance?o.pannerAttr.refDistance:n._refDistance,rolloffFactor:"undefined"!==typeof o.pannerAttr.rolloffFactor?o.pannerAttr.rolloffFactor:n._rolloffFactor,panningModel:"undefined"!==typeof o.pannerAttr.panningModel?o.pannerAttr.panningModel:n._panningModel}}}else if(2===t.length){o=t[0];r=parseInt(t[1],10)}var i=n._getSoundIds(r);for(var u=0;u<i.length;u++){a=n._soundById(i[u]);if(a){var d=a._pannerAttr;d={coneInnerAngle:"undefined"!==typeof o.coneInnerAngle?o.coneInnerAngle:d.coneInnerAngle,coneOuterAngle:"undefined"!==typeof o.coneOuterAngle?o.coneOuterAngle:d.coneOuterAngle,coneOuterGain:"undefined"!==typeof o.coneOuterGain?o.coneOuterGain:d.coneOuterGain,distanceModel:"undefined"!==typeof o.distanceModel?o.distanceModel:d.distanceModel,maxDistance:"undefined"!==typeof o.maxDistance?o.maxDistance:d.maxDistance,refDistance:"undefined"!==typeof o.refDistance?o.refDistance:d.refDistance,rolloffFactor:"undefined"!==typeof o.rolloffFactor?o.rolloffFactor:d.rolloffFactor,panningModel:"undefined"!==typeof o.panningModel?o.panningModel:d.panningModel};var s=a._panner;if(s){s.coneInnerAngle=d.coneInnerAngle;s.coneOuterAngle=d.coneOuterAngle;s.coneOuterGain=d.coneOuterGain;s.distanceModel=d.distanceModel;s.maxDistance=d.maxDistance;s.refDistance=d.refDistance;s.rolloffFactor=d.rolloffFactor;s.panningModel=d.panningModel}else{a._pos||(a._pos=n._pos||[0,0,-.5]);setupPanner(a,"spatial")}}}return n};
/**
   * Add new properties to the core Sound init.
   * @param  {Function} _super Core Sound init method.
   * @return {Sound}
   */Sound.prototype.init=function(n){return function(){var t=this||e;var o=t._parent;t._orientation=o._orientation;t._stereo=o._stereo;t._pos=o._pos;t._pannerAttr=o._pannerAttr;n.call(this||e);t._stereo?o.stereo(t._stereo):t._pos&&o.pos(t._pos[0],t._pos[1],t._pos[2],t._id)}}(Sound.prototype.init);
/**
   * Override the Sound.reset method to clean up properties from the spatial plugin.
   * @param  {Function} _super Sound reset method.
   * @return {Sound}
   */Sound.prototype.reset=function(n){return function(){var t=this||e;var o=t._parent;t._orientation=o._orientation;t._stereo=o._stereo;t._pos=o._pos;t._pannerAttr=o._pannerAttr;if(t._stereo)o.stereo(t._stereo);else if(t._pos)o.pos(t._pos[0],t._pos[1],t._pos[2],t._id);else if(t._panner){t._panner.disconnect(0);t._panner=void 0;o._refreshBuffer(t)}return n.call(this||e)}}(Sound.prototype.reset);
/**
   * Create a new panner node and save it on the sound.
   * @param  {Sound} sound Specific sound to setup panning on.
   * @param {String} type Type of panner to create: 'stereo' or 'spatial'.
   */var setupPanner=function(e,n){n=n||"spatial";if("spatial"===n){e._panner=Howler.ctx.createPanner();e._panner.coneInnerAngle=e._pannerAttr.coneInnerAngle;e._panner.coneOuterAngle=e._pannerAttr.coneOuterAngle;e._panner.coneOuterGain=e._pannerAttr.coneOuterGain;e._panner.distanceModel=e._pannerAttr.distanceModel;e._panner.maxDistance=e._pannerAttr.maxDistance;e._panner.refDistance=e._pannerAttr.refDistance;e._panner.rolloffFactor=e._pannerAttr.rolloffFactor;e._panner.panningModel=e._pannerAttr.panningModel;if("undefined"!==typeof e._panner.positionX){e._panner.positionX.setValueAtTime(e._pos[0],Howler.ctx.currentTime);e._panner.positionY.setValueAtTime(e._pos[1],Howler.ctx.currentTime);e._panner.positionZ.setValueAtTime(e._pos[2],Howler.ctx.currentTime)}else e._panner.setPosition(e._pos[0],e._pos[1],e._pos[2]);if("undefined"!==typeof e._panner.orientationX){e._panner.orientationX.setValueAtTime(e._orientation[0],Howler.ctx.currentTime);e._panner.orientationY.setValueAtTime(e._orientation[1],Howler.ctx.currentTime);e._panner.orientationZ.setValueAtTime(e._orientation[2],Howler.ctx.currentTime)}else e._panner.setOrientation(e._orientation[0],e._orientation[1],e._orientation[2])}else{e._panner=Howler.ctx.createStereoPanner();e._panner.pan.setValueAtTime(e._stereo,Howler.ctx.currentTime)}e._panner.connect(e._node);e._paused||e._parent.pause(e._id,true).play(e._id,true)}})();const t=n.Howler,o=n.Howl;export default n;export{o as Howl,t as Howler};

