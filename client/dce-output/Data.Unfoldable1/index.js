// Generated by purs version 0.13.6
"use strict";
var $foreign = require("./foreign.js");
var Data_Maybe = require("../Data.Maybe/index.js");
var Data_Tuple = require("../Data.Tuple/index.js");
var Unfoldable1 = function (unfoldr1) {
    this.unfoldr1 = unfoldr1;
};
var unfoldable1Array = new Unfoldable1($foreign.unfoldr1ArrayImpl(Data_Maybe.isNothing)(Data_Maybe.fromJust())(Data_Tuple.fst)(Data_Tuple.snd));
module.exports = {
    Unfoldable1: Unfoldable1,
    unfoldable1Array: unfoldable1Array
};