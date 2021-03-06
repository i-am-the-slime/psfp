module Yoga.Typography.Stories where

import Prelude hiding (add)

import Data.Maybe (Maybe(..))
import Effect (Effect)
import Storybook.Decorator.FullScreen (fullScreenDecorator)
import Storybook.React (NodeModule, Storybook, add, addDecorator, storiesOf)
import Yoga.Typography.Header (HeadingLevel(..), mkH)

stories ∷ NodeModule -> Effect Storybook
stories = do
  storiesOf "Typography" do
    addDecorator fullScreenDecorator
    add "All" mkH
      [ { text: "A first level heading", level: H1, className: Nothing }
      , { text: "Second level", level: H2, className: Nothing }
      , { text: "A long third level heading", level: H3, className: Nothing }
      , { text: "Finally, a pretty long h4 heading", level: H4, className: Nothing }
      , { text: "A subheading", level: Subheading, className: Nothing }
      ]
    add "H1" mkH
      [ { text: "Purescript (H1)", level: H1, className: Nothing } ]
    add "H2" mkH
      [ { text: "Purescript (H2)", level: H2, className: Nothing } ]
    add "H3" mkH
      [ { text: "Purescript (H3)", level: H3, className: Nothing } ]
    add "H4" mkH
      [ { text: "Purescript (H4)", level: H4, className: Nothing } ]
    add "H5" mkH
      [ { text: "Purescript (H5)", level: Subheading, className: Nothing } ]

loremIpsum ∷ String
loremIpsum =
  """PureScript is a strongly-typed, purely-functional programming language that compiles"""
    <> """to JavaScript. It can be used to develop web applications, server side apps, and als"""
    <> """o desktop applications with use of Electron. Its syntax is mostly comparable to that"""
    <> """of Haskell. In addition, it introduces row polymorphism and extensible records.[2] A"""
    <> """lso, contrary to Haskell, PureScript adheres to a strict evaluation strategy."""
