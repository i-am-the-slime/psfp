module Yoga.DOM.Hook where

import Prelude
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Data.Nullable (Nullable)
import Data.Nullable as Nullable
import Data.Traversable (for_)
import Data.Tuple.Nested (type (/\))
import React.Basic (Ref)
import React.Basic.Hooks (Hook, UseLayoutEffect, UseRef, UseState, coerceHook, readRefMaybe, useLayoutEffect, useRef, useState, (/\))
import React.Basic.Hooks as React
import Unsafe.Coerce (unsafeCoerce)
import Web.DOM (Node)
import Web.DOM.Element (clientHeight, clientWidth)
import Web.HTML (window)
import Web.HTML.HTMLDocument as Document
import Web.HTML.HTMLElement (DOMRect, focus, getBoundingClientRect)
import Web.HTML.HTMLElement as HTMLElement
import Web.HTML.Window (document)

newtype UseBoundingBox hooks = UseBoundingBox
  ( UseLayoutEffect Unit
      ( UseState (Maybe DOMRect)
          (UseRef (Nullable Node) hooks)
      )
  )

derive instance ntUseBoundingBox ∷ Newtype (UseBoundingBox hooks) _

useBoundingBox ∷ Hook UseBoundingBox (Maybe DOMRect /\ Ref (Nullable Node))
useBoundingBox =
  coerceHook React.do
    (nullableRef ∷ (Ref (Nullable Node))) <- useRef Nullable.null
    bb /\ modifyBb <- useState Nothing
    useLayoutEffect unit do
      maybeRef <- readRefMaybe nullableRef
      let toHTMLOrSVGElement = unsafeCoerce -- [TODO] Make a bit safer?
      for_ (maybeRef <#> toHTMLOrSVGElement) \elem -> do
        rect <- getBoundingClientRect elem
        modifyBb (const $ Just rect)
      pure (pure unit)
    pure (bb /\ nullableRef)

newtype UseViewportHeight hooks = UseViewportHeight (UseLayoutEffect Unit (UseState (Maybe Number) hooks))

derive instance ntUseViewportHeight ∷ Newtype (UseViewportHeight hooks) _

useViewportHeight ∷ Hook UseViewportHeight (Maybe Number)
useViewportHeight =
  coerceHook React.do
    viewportHeight /\ modifyViewportHeight <- useState Nothing
    useLayoutEffect unit do
      doc <- window >>= document
      let maybeElem = Document.toNode doc # HTMLElement.fromNode
      case maybeElem of
        Nothing -> pure unit
        Just elem -> do
          ch <- clientHeight (HTMLElement.toElement elem)
          modifyViewportHeight (const $ Just ch)
      pure (pure unit)
    pure viewportHeight

newtype UseViewportWidth hooks = UseViewportWidth (UseLayoutEffect Unit (UseState (Maybe Number) hooks))

derive instance ntUseViewportWidth ∷ Newtype (UseViewportWidth hooks) _

useViewportWidth ∷ Hook UseViewportWidth (Maybe Number)
useViewportWidth =
  coerceHook React.do
    viewportWidth /\ modifyViewportWidth <- useState Nothing
    useLayoutEffect unit do
      doc <- window >>= document
      let maybeElem = Document.toNode doc # HTMLElement.fromNode
      case maybeElem of
        Nothing -> pure unit
        Just elem -> do
          ch <- clientWidth (HTMLElement.toElement elem)
          modifyViewportWidth (const $ Just ch)
      pure (pure unit)
    pure viewportWidth

newtype UseFocus hooks = UseFocus (UseLayoutEffect Unit (UseRef (Nullable Node) (UseState Boolean hooks)))

derive instance ntUseFocus ∷ Newtype (UseFocus hooks) _

useFocus ∷ Hook UseFocus (Ref (Nullable Node))
useFocus =
  coerceHook React.do
    focussed /\ updateFocussed <- useState false
    ref <- useRef Nullable.null
    useLayoutEffect unit
      $ mempty -- No callback
      <* unless focussed do
          maybeNode <- readRefMaybe ref
          for_ (maybeNode >>= HTMLElement.fromNode) focus
          updateFocussed (const true)
    pure ref
