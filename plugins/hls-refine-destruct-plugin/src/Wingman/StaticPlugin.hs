{-# LANGUAGE CPP #-}

module Wingman.StaticPlugin
  ( staticPlugin
  ) where

import Development.IDE.GHC.Compat
import Development.IDE.GHC.Compat.Util
import GHC.LanguageExtensions.Type (Extension(EmptyCase, QuasiQuotes))

import Ide.Types

#if __GLASGOW_HASKELL__ >= 808
import Data.Data
import Generics.SYB
#if __GLASGOW_HASKELL__ >= 900
import GHC.Driver.Plugins (purePlugin)
#else
import Plugins (purePlugin)
#endif
#endif

staticPlugin :: DynFlagsModifications
staticPlugin = mempty
  { dynFlagsModifyGlobal =
      \df -> allowEmptyCaseButWithWarning
           $ flip gopt_unset Opt_SortBySubsumHoleFits
           $ flip gopt_unset Opt_ShowValidHoleFits
           $ df
             { refLevelHoleFits = Just 0
             , maxRefHoleFits   = Just 0
             , maxValidHoleFits = Just 0
#if __GLASGOW_HASKELL__ >= 808
             , staticPlugins = staticPlugins df
#endif
             }
  }


-- | Wingman wants to support destructing of empty cases, but these are a parse
-- error by default. So we want to enable 'EmptyCase', but then that leads to
-- silent errors without 'Opt_WarnIncompletePatterns'.
allowEmptyCaseButWithWarning :: DynFlags -> DynFlags
allowEmptyCaseButWithWarning =
  flip xopt_set EmptyCase . flip wopt_set Opt_WarnIncompletePatterns

