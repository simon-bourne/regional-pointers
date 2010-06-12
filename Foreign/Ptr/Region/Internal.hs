{-# LANGUAGE UnicodeSyntax
           , NoImplicitPrelude
           , KindSignatures
  #-}

-------------------------------------------------------------------------------
-- |
-- Module      :  Foreign.Ptr.Region.Internal
-- Copyright   :  (c) 2010 Bas van Dijk
-- License     :  BSD3 (see the file LICENSE)
-- Maintainer  :  Bas van Dijk <v.dijk.bas@gmail.com>
--
-------------------------------------------------------------------------------

module Foreign.Ptr.Region.Internal
    ( -- * Regional pointers
      RegionalPtr(RegionalPtr)

      -- * Utility functions for lifting operations on Ptrs to RegionalPtrs
    , unsafePtr
    , unsafeWrap, unsafeWrap2, unsafeWrap3
    ) where


--------------------------------------------------------------------------------
-- Imports
--------------------------------------------------------------------------------

-- from base:
import Control.Monad ( return, (>>=), fail )
import Data.Function ( ($) )
import Data.Maybe    ( Maybe(Nothing, Just) )
import System.IO     ( IO )
import Foreign.Ptr   ( Ptr )

-- from transformers:
import Control.Monad.IO.Class ( MonadIO, liftIO )

-- from regions:
import Control.Monad.Trans.Region.OnExit ( CloseHandle )
import Control.Monad.Trans.Region        ( Dup(dup) )


--------------------------------------------------------------------------------
-- * Regional pointers
--------------------------------------------------------------------------------

-- | A regional handle to memory. This should provide a safer replacement for
-- @Foreign.Ptr.'Ptr'@
data RegionalPtr α (r ∷ * → *) = RegionalPtr (Ptr α) (Maybe (CloseHandle r))

instance Dup (RegionalPtr α) where
    dup (RegionalPtr ptr Nothing)   = return $ RegionalPtr ptr Nothing
    dup (RegionalPtr ptr (Just ch)) = do ch' ← dup ch
                                         return $ RegionalPtr ptr $ Just ch'


--------------------------------------------------------------------------------
-- * Utility functions for lifting operations on Ptrs to RegionalPtrs
--------------------------------------------------------------------------------

unsafePtr ∷ RegionalPtr α r → Ptr α
unsafePtr (RegionalPtr ptr _) = ptr

unsafeWrap ∷ MonadIO m
           ⇒ (Ptr α → IO β)
           → (RegionalPtr α r → m β)
unsafeWrap f rp = liftIO $ f $ unsafePtr rp

unsafeWrap2 ∷ MonadIO m
            ⇒ (Ptr α → γ → IO β)
            → (RegionalPtr α r → γ → m β)
unsafeWrap2 f rp x = liftIO $ f (unsafePtr rp) x

unsafeWrap3 ∷ MonadIO m
            ⇒ (Ptr α → γ → δ → IO β)
            → (RegionalPtr α r → γ → δ → m β)
unsafeWrap3 f rp x y = liftIO $ f (unsafePtr rp) x y


-- The End ---------------------------------------------------------------------
