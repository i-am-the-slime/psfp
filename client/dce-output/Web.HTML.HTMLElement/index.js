// Generated by purs version 0.13.6
"use strict";
var $foreign = require("./foreign.js");
var Data_Maybe = require("../Data.Maybe/index.js");
var fromNode = function (x) {
    return $foreign["_read"](Data_Maybe.Nothing.value, Data_Maybe.Just.create, x);
};
module.exports = {
    fromNode: fromNode,
    getBoundingClientRect: $foreign.getBoundingClientRect,
    offsetTop: $foreign.offsetTop
};