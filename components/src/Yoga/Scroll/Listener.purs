module Yoga.Scroll.Listener (registerListener) where

import Prelude
import Effect (Effect)
import Web.Event.Event (EventType(..))
import Web.Event.EventTarget (EventListener, addEventListener, removeEventListener)
import Web.HTML (window)
import Web.HTML.Window (toEventTarget)

eventType ∷ EventType
eventType = EventType "scroll"

registerListener ∷ EventListener -> Effect (Effect Unit)
registerListener listener = do
  target <- window <#> toEventTarget
  addEventListener eventType listener false target
  pure $ removeEventListener eventType listener false target
