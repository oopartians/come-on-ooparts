(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);throw new Error("Cannot find module '"+o+"'")}var f=n[o]={exports:{}};t[o][0].call(f.exports,function(e){var n=t[o][1][e];return s(n?n:e)},f,f.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var app, get_cookie, get_cookie_chunks, set_cookie, set_cookie_chunks;

app = angular.module('loginApp');

get_cookie_chunks = function() {
  return document.cookie.split(';').map(function(chunk) {
    var lhs, ref, rhs;
    ref = chunk.split('='), lhs = ref[0], rhs = ref[1];
    return {
      key: lhs.trim(),
      value: rhs.trim()
    };
  });
};

set_cookie_chunks = function(list) {
  return document.cookie = list.map(function(c) {
    return c.key + "=" + c.value;
  }).join('; ');
};

get_cookie = function(key) {
  var _ref, cookie;
  cookie = document.cookie;
  if (cookie == null) {
    return null;
  }
  _ref = _.find(get_cookie_chunks(), function(c) {
    return c.key === key;
  });
  if (_ref != null) {
    return _ref.value;
  } else {
    return null;
  }
};

set_cookie = function(key, value) {
  var _ref, chunks;
  chunks = get_cookie_chunks();
  _ref = _.find(chunks, function(c) {
    return c.key === key;
  });
  if (_ref != null) {
    _ref.value = value;
  } else {
    chunks.push({
      key: key,
      value: value
    });
  }
  return set_cookie_chunks(chunks);
};

app.controller('LoginCtrl', [
  '$scope', '$resource', function($scope, $resource) {
    var R_session;
    R_session = $resource("/auth/session");
    return $scope.login = function(name, pw) {
      return R_session.save({}, {
        name: name,
        password: pw
      }, function(data) {
        get_cookie(data);
        return console.log("succeeded!");
      }, function(err) {
        return alert("got error : " + (JSON.stringify(err)));
      });
    };
  }
]);



},{}]},{},[1])