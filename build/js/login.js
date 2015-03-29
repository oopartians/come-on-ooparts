(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);throw new Error("Cannot find module '"+o+"'")}var f=n[o]={exports:{}};t[o][0].call(f.exports,function(e){var n=t[o][1][e];return s(n?n:e)},f,f.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var app, get_cookie, get_cookie_chunks, set_cookie, set_cookie_chunks;

app = angular.module('loginApp', ['ngResource']);

app.run(function() {});

get_cookie_chunks = function() {
  return document.cookie.split(';').map(function(chunk) {
    var lhs, ref, rhs;
    if (chunk == null) {
      return;
    }
    if (!chunk.trim()) {
      return;
    }
    ref = chunk.split('='), lhs = ref[0], rhs = ref[1];
    return {
      key: lhs.trim(),
      value: rhs.trim()
    };
  }).filter(function(a) {
    return a != null;
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
    console.log("session_token : " + (get_cookie("session_token")));
    console.log("redirect_url : " + redirect_url);
    return $scope.login = function(name, pw) {
      return R_session.save({}, {
        name: name,
        password: pw
      }, function(data) {
        console.log("succeeded to get token : " + data.session_token);
        set_cookie("session_token", data.session_token);
        return location.href = redirect_url;
      }, function(err) {
        var ref, ref1;
        if ((ref = err.data) != null ? ref.error = "NoSuchMember" : void 0) {
          return alert("해당 이름과 비밀번호를 가진 멤버를 찾지 못했습니다.");
        } else if (((ref1 = err.data) != null ? ref1.error : void 0) != null) {
          return alert("로그인 실패 : " + err.data.error);
        } else {
          return alert("로그인 실패");
        }
      });
    };
  }
]);



},{}]},{},[1])