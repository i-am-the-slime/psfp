module Yoga.Editor where

import Prelude
import CSS (borderBox, borderRadius, boxSizing, margin, padding, pct, px, toHexString, unitless, width)
import CSS.Overflow (hidden, overflowY)
import Control.Promise (Promise)
import Control.Promise as Promise
import Data.Foldable (for_)
import Data.Maybe (Maybe(..), maybe)
import Data.Nullable (Nullable)
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Aff.Compat (EffectFn1)
import Effect.Class (liftEffect)
import Effect.Uncurried (EffectFn2, mkEffectFn1, mkEffectFn2)
import Foreign (Foreign, unsafeToForeign)
import JSS (jssClasses)
import Prim.Row (class Union)
import React.Basic (JSX, ReactComponent, Ref, element, fragment)
import React.Basic.DOM as R
import React.Basic.Hooks (reactComponent, useEffect, useState)
import React.Basic.Hooks as React
import React.Basic.Hooks.Aff (useAff)
import Web.DOM (Node)
import Web.HTML (HTMLElement)
import Yoga.Theme (fromTheme)
import Yoga.Theme.Default (darkTheme)
import Yoga.Theme.Styles (makeStylesJSS)
import Yoga.Theme.Types (CSSTheme)

type EditorProps =
  ( value ∷ String
  , language ∷ String
  , editorDidMount ∷ EffectFn2 Editor Node Unit
  , editorWillMount ∷ EffectFn1 Monaco Unit
  , theme ∷ String
  , line ∷ Number
  , ref ∷ Ref (Nullable HTMLElement)
  , width ∷ String
  , height ∷ String
  , loading ∷ JSX
  , options ∷ Foreign
  )

foreign import monacoEditorImpl ∷ ∀ attrs. Effect (Promise (ReactComponent { | attrs }))

foreign import defineThemeImpl ∷ Monaco -> String -> MonacoTheme -> Effect Unit

foreign import setThemeImpl ∷ Monaco -> String -> Effect Unit

foreign import nightOwlTheme ∷ String -> MonacoTheme

foreign import vsCodeTheme ∷ String -> MonacoTheme

foreign import getValue ∷ Editor -> Effect String

foreign import setValue ∷ String -> Editor -> Effect Unit

foreign import colorizeImpl ∷ String -> String -> { tabSize ∷ Int } -> Editor -> Promise String

foreign import data Monaco ∷ Type

foreign import data Editor ∷ Type

foreign import data MonacoTheme ∷ Type

monacoEditor ∷ ∀ attrs attrs_. Union attrs attrs_ EditorProps => Aff (ReactComponent { | attrs })
monacoEditor = do
  prom <- monacoEditorImpl # liftEffect
  Promise.toAff prom

darkThemeName ∷ String
darkThemeName = "NightOwl"

lightThemeName ∷ String
lightThemeName = "VSCode"

foreign import data MonarchLanguage ∷ Type

foreign import purescriptSyntax ∷ MonarchLanguage

foreign import registerLanguageImpl ∷ Monaco -> String -> Effect Unit

foreign import setMonarchTokensProviderImpl ∷ Monaco -> String -> MonarchLanguage -> Effect Unit

initEditor ∷ CSSTheme -> Monaco -> Effect Unit
initEditor theme monaco = do
  defineThemeImpl monaco darkThemeName (nightOwlTheme (toHexString theme.backgroundColour))
  defineThemeImpl monaco lightThemeName (vsCodeTheme (toHexString theme.backgroundColour))
  registerLanguageImpl monaco "purescript"
  setMonarchTokensProviderImpl monaco "purescript" purescriptSyntax

type Props =
  { onLoad ∷ Editor -> Effect Unit
  , height ∷ String
  , language ∷ String
  }

mkEditor ∷ Effect (ReactComponent Props)
mkEditor = do
  useStyles <-
    makeStylesJSS
      $ jssClasses \_ ->
          { wrapper:
            do
              margin (0.0 # unitless) (0.0 # unitless) (0.0 # unitless) (0.0 # unitless)
              boxSizing borderBox
              borderRadius (8.0 # px) (8.0 # px) (8.0 # px) (8.0 # px)
              width (100.0 # pct)
              overflowY hidden
          -- backgroundColor (colour.background) [TODO]
          }
  reactComponent "Editor" \{ onLoad, height, language } -> React.do
    classes <- useStyles {}
    maybeEditor /\ modifyEditor <- useState Nothing
    maybeMonaco /\ modifyMonaco <- useState Nothing
    useAff unit do
      eddy <- monacoEditor
      liftEffect $ modifyEditor (const (Just eddy))
    useEffect unit do -- [TODO] notice theme change
      for_ maybeMonaco (initEditor (fromTheme darkTheme))
      pure mempty
    let themeName = darkThemeName
    pure
      $ fragment
          [ R.div
              { className: classes.wrapper
              , children:
                [ maybeEditor
                    # maybe mempty \editor ->
                        element editor
                          { theme: themeName
                          , height
                          , options:
                            unsafeToForeign
                              { fontFamily: "Victor Mono"
                              , fontLigatures: true
                              , fontSize: "var(--s0)"
                              , lineNumbers: "off"
                              , glyphMargin: false
                              , folding: false
                              , lineDecorationsWidth: 0
                              , lineNumbersMinChars: 0
                              , minimap: { enabled: false }
                              , scrollBeyondLastLine: false
                              , scrollbar: { vertical: "hidden", verticalScrollBarSize: 20 }
                              , hideCursorInOverviewRuler: true
                              , overviewRulerBorder: false
                              }
                          , language
                          -- https://microsoft.github.io/monaco-editor/playground.html#extending-language-services-custom-languages
                          , editorDidMount: mkEffectFn2 \e _ -> onLoad e
                          , editorWillMount:
                            mkEffectFn1 \m -> do
                              modifyMonaco (const $ Just m)
                              (initEditor (fromTheme darkTheme) m)
                          }
                ]
              }
          ]
