module Storybook.React
  ( storiesOf
  , Storybook
  , add
  , add_
  , addDecorator
  , NodeModule
  , Stories
  ) where

import Prelude hiding (add)
import Control.Monad.Reader (ReaderT, ask, lift, local, runReaderT)
import Effect (Effect)
import React.Basic (JSX, ReactComponent, element, fragment)

foreign import data Storybook ∷ Type

foreign import data NodeModule ∷ Type

foreign import storiesOfImpl ∷ String -> NodeModule -> Storybook

foreign import addImpl ∷ Storybook -> Effect JSX -> String -> Effect Storybook

foreign import addDecoratorImpl ∷
  Storybook ->
  (Effect JSX -> Effect JSX) ->
  Effect Storybook

add ∷ ∀ props. String -> Effect (ReactComponent { | props }) -> Array { | props } -> ReaderT Storybook Effect Unit
add name mkComponent propsArray = do
  sb <- ask
  let
    component = do
      comp <- mkComponent
      pure $ fragment $ propsArray <#> element comp
  newBook <- lift $ addImpl sb component name
  local (const newBook) (pure unit)

add_ ∷ String -> JSX -> ReaderT Storybook Effect Unit
add_ name jsx = do
  sb <- ask
  newBook <- lift $ addImpl sb (pure jsx) name
  local (const newBook) (pure unit)

addDecorator ∷ (Effect JSX -> Effect JSX) -> ReaderT Storybook Effect Unit
addDecorator decorate = do
  sb <- ask
  newBook <-
    lift
      $ addDecoratorImpl sb decorate
  local (const newBook) (pure unit)

type Stories
  = NodeModule -> Effect Storybook

storiesOf ∷ ∀ a. String -> ReaderT Storybook Effect a -> Stories
storiesOf name program module' = do
  runReaderT (program *> ask) (storiesOfImpl name module')
