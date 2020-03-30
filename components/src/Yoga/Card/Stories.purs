module Yoga.Card.Stories where

import Prelude hiding (add)
import Effect (Effect)
import React.Basic.DOM as R
import React.Basic.Helpers (jsx)
import React.Basic.Hooks (component)
import Storybook.Decorator.FullScreen (fullScreenDecorator)
import Storybook.React (Storybook, add, addDecorator, storiesOf)
import Yoga.Box.Component as Box
import Yoga.Card.Component (mkCard)

stories ∷ Effect Storybook
stories = do
  storiesOf "Card" do
    addDecorator fullScreenDecorator
    add "Example card" mkExample
      [ { title: "An example card"
        , subtitle: "It says some more"
        , content: R.text loremIpsum
        }
      ]
  where
  mkExample = do
    box <- Box.makeComponent
    card <- mkCard
    component "ExampleCard" \{ title, subtitle, content } -> React.do
      pure
        $ jsx box {}
            [ jsx card {}
                [ R.text "hi there!" ]
            ]

loremIpsum ∷ String
loremIpsum =
  """PureScript is a strongly-typed, purely-functional programming language that compiles"""
    <> """ to JavaScript. It can be used to develop web applications, server side apps, and al"""
    <> """so desktop applications with use of Electron. Its syntax is mostly comparable to tha"""
    <> """t of Haskell. In addition, it introduces row polymorphism and extensible records.[2]"""
    <> """ Also, contrary to Haskell, PureScript adheres to a strict evaluation strategy."""