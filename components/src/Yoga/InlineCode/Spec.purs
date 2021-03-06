module Yoga.InlineCode.Spec where

import Prelude

import Data.Maybe (Maybe(..))
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Aff (Aff, Milliseconds(..))
import Effect.Class (liftEffect)
import Effect.Ref (Ref)
import Effect.Ref as Ref
import Justifill (justifill)
import React.Basic.Extra.Hooks.UseAffReducer (useAffReducer)
import React.Basic.Hooks (ReactComponent, element, reactComponent, useEffect)
import React.Basic.Hooks as React
import React.TestingLibrary (describeComponent, renderComponent)
import Test.Spec (Spec, it)
import Web.Event.Internal.Types (Event)
import Yoga.InlineCode.Component as InlineCode
import Yoga.Spec.Helpers (withSpecTheme)

foreign import newInputEvent ∷ String -> Event

foreign import newChangeEvent ∷ Event

spec ∷ Spec Unit
spec =
  describeComponent (withSpecTheme mkWrapper)
    "The InlineCode Component" do
    it "renders without problems" \wrapper -> do
      strRef <- Ref.new "" # liftEffect
      void $ renderComponent wrapper { strRef }

-- it "performs actions" \wrapper -> do
--   strRef <- Ref.new "" # liftEffect
--   { findByTestId } <- renderComponent wrapper { strRef }
--   input <- findByTestId "inline-code"
--   focus input # liftEffect
--   typeText "Heinzelmän" input
--   fireEventSubmit input
--   refContent <- Ref.read strRef # liftEffect
--   refContent `shouldEqual` "Heinzelmän"
data Action
  = InlineCodeAction String

derive instance eqAction ∷ Eq Action
mkReducer ∷ Ref String -> Maybe String -> Action -> Aff (Maybe String)
mkReducer ref state = case _ of
  InlineCodeAction s -> do
    Ref.write s ref # liftEffect
    pure state

mkWrapper ∷ Effect (ReactComponent { strRef ∷ Ref String })
mkWrapper = do
  inlineCode <- InlineCode.makeComponent
  reactComponent "Wrapper" \{ strRef } -> React.do
    state /\ dispatch <- useAffReducer Nothing (mkReducer strRef)
    useEffect state mempty
    pure
      $ element inlineCode
          ( justifill
              { update: dispatch <<< InlineCodeAction
              , debounceBy: 0.0 # Milliseconds
              }
          )
