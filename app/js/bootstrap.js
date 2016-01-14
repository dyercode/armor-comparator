window.body = function() {
  html = JST['app/templates/body.us']();
  document.body.innerHTML += html;
};

window.gtm = function() {
  html = JST['app/templates/gtm.us']();
  document.body.innerHTML += html;
};

if(window.addEventListener) {
  window.addEventListener('DOMContentLoaded', gtm, false);
  window.addEventListener('DOMContentLoaded', body, false);
} else {
  window.attachEvent('onload', gtm);
  window.attachEvent('onload', body);
}