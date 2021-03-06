module Yoga.Typography.Header where

import Prelude
import Color (toHexString)
import Data.Array as Array
import Data.Array.NonEmpty as NEA
import Data.Foldable (intercalate)
import Data.Maybe (Maybe)
import Effect (Effect)
import JSS (jssClasses)
import React.Basic.DOM as R
import React.Basic.Hooks (ReactComponent, reactComponent)
import React.Basic.Hooks as React
import Yoga.Theme.Styles (makeStylesJSS)
import Yoga.Theme.Types (CSSTheme)

data HeadingLevel
  = H1
  | H2
  | H3
  | H4
  | Subheading

mkH ∷
  Effect (ReactComponent { level ∷ HeadingLevel, text ∷ String, className ∷ Maybe String })
mkH = do
  useStyles <-
    makeStylesJSS
      $ jssClasses \(theme ∷ CSSTheme) ->
          { common:
            { color: theme.textColour # toHexString
            , fontFamily: NEA.head theme.headingFontFamily
            }
          , h1:
            { -- textTransform: "uppercase"
            fontWeight: "bold"
            , margin: 0
            , padding: 0
            }
          , h2:
            { -- textTransform: "uppercase"
            -- , fontSize: "3em"
             letterSpacing: "0.05em"
            , margin: 0
            , padding: 0
            }
          , h3:
            { fontSize: "2.2em"
            , margin: 0
            , padding: 0
            }
          , h4:
            { fontSize: "1.5em"
            , margin: 0
            , padding: 0
            }
          , h5:
            { fontSize: "1.0em"
            , margin: 0
            , padding: 0
            , color: theme.textColourLighter # toHexString
            }
          }
  reactComponent "Heading" \{ level, text, className } -> React.do
    classes <- useStyles {}
    let
      elem = case level of
        H1 -> R.h1
        H2 -> R.h2
        H3 -> R.h3
        H4 -> R.h4
        Subheading -> R.h5
    let
      specificClassName = case level of
        H1 -> classes.h1
        H2 -> classes.h2
        H3 -> classes.h3
        H4 -> classes.h4
        Subheading -> classes.h5
    pure
      $ elem
          ( { className:
              intercalate " "
                $ [ classes.common, specificClassName ]
                <> Array.fromFoldable className
            , children: [ R.text text ]
            }
          )
