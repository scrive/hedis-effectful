{-# LANGUAGE UndecidableInstances #-}
{-# OPTIONS_GHC -Wno-orphans #-}

-- | Access to a Redis database via 'MonadRedis'.
module Effectful.Redis
  ( -- * Effect
    Redis

    -- * Handler
  , runRedis
  )
where

import qualified Database.Redis as R
import Effectful
import Effectful.Dispatch.Static

-- | Provide the ability to use the 'R.MonadRedis' instance of 'Eff'.
data Redis :: Effect

type instance DispatchOf Redis = Static WithSideEffects

newtype instance StaticRep Redis = Redis R.Connection

-- | Run the redis effect.
runRedis :: (IOE :> es) => R.Connection -> Eff (Redis : es) a -> Eff es a
runRedis = evalStaticRep . Redis

----------------------------------------
-- Orphan instance

instance (IOE :> es, Redis :> es) => R.MonadRedis (Eff es) where
  liftRedis redis = do
    Redis connection <- getStaticRep
    liftIO $ R.runRedis connection redis
