{-# LANGUAGE UndecidableInstances #-}
{-# OPTIONS_GHC -Wno-orphans #-}

-- | Access to a Redis database via 'MonadRedis'.
module Effectful.Redis
  ( -- * Effect
    Redis (..)

    -- * Handler
  , runRedis
  )
where

import Database.Redis qualified as R
import Effectful
import Effectful.Dispatch.Dynamic

-- | Provide the ability to use the 'R.MonadRedis' instance of 'Eff'.
data Redis :: Effect where
  LiftRedis :: R.Redis a -> Redis m a

type instance DispatchOf Redis = Dynamic

-- | Run the redis effect.
runRedis :: IOE :> es => R.Connection -> Eff (Redis : es) a -> Eff es a
runRedis conn = interpret $ \_ -> \case
  LiftRedis action -> liftIO $ R.runRedis conn action

----------------------------------------
-- Orphan instance

instance Redis :> es => R.MonadRedis (Eff es) where
  liftRedis = send . LiftRedis
