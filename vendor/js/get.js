var myget = function (url) {
	"use strict";
	return new Promise(function (resolve, reject) {
		var http = new XMLHttpRequest();
		http.onload = function () {
			resolve(http.response);
		};
		http.onerror = function () {
			reject({success: false, message: 'Connection Error.'});
		};
		http.open('get', url, true);
		http.send();
	});
};