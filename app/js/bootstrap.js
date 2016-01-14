window.body = function() {
  html = JST['app/templates/body.us']();
  document.body.innerHTML += html;
};

if(window.addEventListener) {
  window.addEventListener('DOMContentLoaded', body, false);
} else {
  window.attachEvent('onload', body);
}