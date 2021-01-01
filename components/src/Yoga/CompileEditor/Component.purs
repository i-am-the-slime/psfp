module Yoga.CompileEditor.Component where

import Prelude hiding (add)
import CSS (JustifyContentValue(..), flexEnd)
import Data.Array (intercalate)
import Data.Either (Either(..))
import Data.Foldable (for_)
import Data.Interpolate (i)
import Data.Maybe (Maybe(..))
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import JSS (jssClasses)
import React.Basic (ReactComponent)
import React.Basic.DOM as R
import React.Basic.Events (handler_)
import React.Basic.Helpers (jsx)
import React.Basic.Hooks (reactComponent, element, useState)
import React.Basic.Hooks as React
import Yoga as Y
import Yoga.Block as Block
import Yoga.Block.Atom.Button.Types as BT
import Yoga.Block.Container.Style (colour)
import Yoga.Card.Component (mkCard)
import Yoga.Cluster.Component as Cluster
import Yoga.Compiler.Types (Compiler)
import Yoga.Editor (getValue, mkEditor, setValue)
import Yoga.Stack.Component as Stack
import Yoga.Theme.Styles (makeStylesJSS)

type Props =
  { initialCode ∷ String, height ∷ String, language ∷ String }

mkCompileEditor ∷ ∀ r. { | Compiler r } -> Effect (ReactComponent Props)
mkCompileEditor { compileAndRun } = do
  editor <- mkEditor
  card <- mkCard
  cluster <- Cluster.makeComponent
  stack <- Stack.makeComponent
  useStyles <-
    makeStylesJSS
      $ jssClasses \_ ->
          { editor:
            { background: colour.background
            , boxSizing: "content-box"
            , height: "80%"
            , padding: "20px"
            , marginTop: "0px"
            , borderRadius: "12px"
            , boxShadow: i "22px 22px 24px " colour.background ", -22px -22px 24px " colour.backgroundLayer1 ∷ String
            , display: "flex"
            , flexDirection: "column"
            -- , minWidth: theme.measure
            }
          , card:
            { zIndex: 0
            }
          , cardHidden: { opacity: 0 }
          , compileError: { color: colour.invalid, opacity: 1, transition: "opacity 2.0s ease" }
          , runOutput: { color: colour.success, opacity: 1, transition: "opacity 2.0s ease" }
          }
  reactComponent "CompileEditor" \{ initialCode, height, language } -> React.do
    maybeEditor /\ modifyEditor <- useState Nothing
    classes <- useStyles {}
    let
      onLoad e = do
        setValue initialCode e
        modifyEditor (const $ Just e)
    compileResult /\ modifyCompileResult <- useState Nothing
    let
      reset = do
        setCompileResult Nothing
        for_ maybeEditor (setValue initialCode)
      compileResultToString = case _ of
        Nothing -> ""
        Just (Left cr) -> cr.result <#> _.message # intercalate "/n"
        Just (Right r) -> r.stdout
      compileResultToClass = case _ of
        Nothing -> classes.cardHidden
        Just (Left cr) -> classes.compileError
        Just (Right r) -> classes.runOutput
      setCompileResult = modifyCompileResult <<< const
      compile = do
        for_ maybeEditor \ed -> do
          setCompileResult Nothing
          code <- getValue ed
          launchAff_ do
            res <- compileAndRun { code }
            setCompileResult (Just res) # liftEffect
    pure
      $ jsx stack { space: "--s1" }
          [ jsx stack { space: "--s0", className: classes.editor }
              [ element editor { onLoad, height, language }
              , jsx cluster { justify: JustifyContentValue flexEnd }
                  [ R.div_
                      [ Y.el Block.button
                          { onClick: handler_ reset
                          }
                          [ R.text "Reset" ]
                      , Y.el Block.button
                          { buttonType: BT.Primary
                          , onClick: handler_ compile
                          }
                          [ R.text "Run" ]
                      ]
                  ]
              ]
          , jsx card
              { className: classes.card <> " " <> compileResultToClass compileResult
              }
              [ R.text (compileResultToString compileResult) ]
          ]
