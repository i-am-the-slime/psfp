{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "ry-blog"
, dependencies =
  [ "console", "effect", "psci-support", "yoga-components" ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
