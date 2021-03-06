module Yoga.Box.Styles where

import Prelude
import Color (toHexString)
import Data.Maybe (Maybe)
import JSS (JSSClasses, JSSElem, jssClasses)
import Yoga.Helpers ((?||))
import Yoga.Theme.Types (YogaTheme)

type PropsR
  = ( padding ∷ Maybe String
    , border ∷ Maybe String
    , invert ∷ Maybe Boolean
    )

type Props
  = Record PropsR

styles ∷
  JSSClasses YogaTheme Props
    ( box ∷ JSSElem Props
    , invert ∷ JSSElem Props
    )
styles =
  jssClasses \theme ->
    { box:
      \props ->
        { padding: props.padding ?|| "var(--s1)"
        , "--colour-light": theme.backgroundColour # toHexString
        , "--colour-dark": theme.textColour # toHexString
        , color: "var(--colour-dark)"
        , backgroundColor: "transparent"
        , border: props.border ?|| "0 solid"
        , outline: theme.borderThin <> " solid transparent"
        , outlineOffset: "-" <> theme.borderThin
        , "& *":
          { color: "inherit"
          }
        }
    , invert:
      \props ->
        { color: "var(--colour-light) !important"
        , backgroundColor: "var(--colour-dark) !important"
        }
    }
