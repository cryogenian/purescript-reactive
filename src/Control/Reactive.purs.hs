module Control.Reactive where

import Prelude
import Control.Monad.Eff
import Data.Monoid
import Control.Monad.Eff.Ref (newRef, readRef, writeRef)
import Control.Monad.Eff.Ref.Unsafe (unsafeRunRef)

-- Reactive variables
foreign import data RVar :: * -> *

-- Reactive collections
foreign import data RArray :: * -> *

-- The effect of using reactive variables
foreign import data Reactive :: !

-- Create a new reactive variable
foreign import newRVar 
  "function newRVar(value) {\
  \  return function() {\
  \    return (function () {\
  \      function RVar(value) {\
  \        var self = this;\
  \        self.value = value;\
  \        self.listeners = [];\
  \        self.subscribe = function (listener) {\
  \          this.listeners.push(listener);\
  \          return module.Subscription(function() {\
  \            for (var i = 0; i < self.listeners.length; i++) {\
  \              if (self.listeners[i] === listener) {\
  \                self.listeners.splice(i, 1);\
  \                break;\
  \              }\
  \            }\
  \          });\
  \        };\
  \        self.update = function (value) {\
  \          self.value = value;\
  \          for (var i = 0; i < self.listeners.length; i++) {\
  \            self.listeners[i](value);\
  \          }\
  \        };\
  \      };\
  \      return new RVar(value);\
  \    })();\
  \  };\
  \}" :: forall a eff. a -> Eff (reactive :: Reactive | eff) (RVar a)

-- Create a new reactive collection
foreign import newRArray 
  "function newRArray() {\
  \    return (function () {\
  \      function RArray() {\
  \        var self = this;\
  \        self.values = [];\
  \        self.listeners = [];\
  \        self.subscribe = function (listener) {\
  \          this.listeners.push(listener);\
  \          return module.Subscription(function() {\
  \            for (var i = 0; i < self.listeners.length; i++) {\
  \              if (self.listeners[i] === listener) {\
  \                self.listeners.splice(i, 1);\
  \                break;\
  \              }\
  \            }\
  \          });\
  \        };\
  \        self.insert = function (value, index) {\
  \          self.values.splice(index, 0, value);\
  \          for (var i = 0; i < self.listeners.length; i++) {\
  \            self.listeners[i](module.Inserted(value)(index));\
  \          }\
  \        };\
  \        self.remove = function (index) {\
  \          self.values.splice(index, 1);\
  \          for (var i = 0; i < self.listeners.length; i++) {\
  \            self.listeners[i](module.Removed(index));\
  \          }\
  \        };\
  \        self.update = function (value, index) {\
  \          self.values[index] = index;\
  \          for (var i = 0; i < self.listeners.length; i++) {\
  \            self.listeners[i](module.Updated(value)(index));\
  \          }\
  \        };\
  \      };\
  \      return new RArray();\
  \    })();\
  \}" :: forall a eff. Eff (reactive :: Reactive | eff) (RArray a)

-- Read the value of a reactive variable
foreign import readRVar 
  "function readRVar(ref) {\
  \  return function() {\
  \    return ref.value;\
  \  };\
  \}" :: forall a eff. RVar a -> Eff (reactive :: Reactive | eff) a

-- Read the values inside a reactive collection
foreign import readRArray 
  "function readRArray(arr) {\
  \  return function() {\
  \    return arr.values;\
  \  };\
  \}" :: forall a eff. RArray a -> Eff (reactive :: Reactive | eff) [a]

-- Write the value of a reactive variable
foreign import writeRVar
  "function writeRVar(ref) {\
  \  return function (value) {\
  \    return function() {\
  \      ref.update(value);\
  \    };\
  \  };\
  \}" :: forall a eff. RVar a -> a -> Eff (reactive :: Reactive | eff) {}

-- Get an element at an index in a reactive collection
foreign import peekRArray 
  "function peekRArray(arr) {\
  \  return function(i) {\
  \    return arr.values[i];\
  \  };\
  \}" :: forall a eff. RArray a -> Number -> Eff (reactive :: Reactive | eff) a

-- Add a value to a reactive collection
foreign import insertRArray 
  "function insertRArray(arr) {\
  \  return function (value) {\
  \    return function(index) {\
  \      return function() {\
  \        arr.insert(value, index);\
  \      };\
  \    };\
  \  };\
  \}" :: forall a eff. RArray a -> a -> Number -> Eff (reactive :: Reactive | eff) {}

-- Remove a value from a reactive collection
foreign import removeRArray 
  "function removeRArray(arr) {\
  \  return function(index) {\
  \    return function() {\
  \      arr.remove(index);\
  \    };\
  \  };\
  \}":: forall a eff. RArray a -> Number -> Eff (reactive :: Reactive | eff) a

-- Update a value in a reactive collection
foreign import updateRArray 
  "function updateRArray(arr) {\
  \  return function (value) {\
  \    return function(index) {\
  \      return function() {\
  \        arr.update(value, index);\
  \      };\
  \    };\
  \  };\
  \}" :: forall a eff. RArray a -> a -> Number -> Eff (reactive :: Reactive | eff) {}

-- Subscription which can be cancelled
data Subscription = Subscription (forall eff. Eff (reactive :: Reactive | eff) {})

instance semigroupSubscription :: Semigroup Subscription where
  (<>) (Subscription cancel1) (Subscription cancel2) = Subscription (do
    cancel1
    cancel2)

instance monoidSubscription :: Data.Monoid.Monoid Subscription where
  mempty = Subscription (return {})

-- Subscribe for updates on an RVar 
foreign import subscribe 
  "function subscribe(ref) {\
  \  return function(f) {\
  \    return function() {\
  \      return ref.subscribe(function(value) {\
  \        f(value)();\
  \      });\
  \    };\
  \  };\
  \}" :: forall a eff. RVar a -> (a -> Eff (reactive :: Reactive | eff) {}) -> Eff (reactive :: Reactive | eff) Subscription

data RArrayChange a
  = Inserted a Number
  | Updated a Number
  | Removed Number

instance showArrayChange :: (Prelude.Show a) => Prelude.Show (RArrayChange a) where
  show (Inserted a n) = "Inserted " ++ show a ++ " at " ++ show n
  show (Updated a n) = "Updated " ++ show n ++ " to " ++ show a
  show (Removed n) = "Removed at index " ++ show n

-- Subscribe for updates on an RArray
foreign import subscribeArray 
  "function subscribeArray(arr) {\
  \  return function(f) {\
  \    return function() {\
  \      return arr.subscribe(function(value) {\
  \        f(value)();\
  \      });\
  \    };\
  \  };\
  \}" :: forall a eff. RArray a -> (RArrayChange a -> Eff (reactive :: Reactive | eff) {}) -> Eff (reactive :: Reactive | eff) Subscription

------------------------------------------------------------------------------------------------

modifyRVar :: forall a eff. RVar a -> (a -> a) -> Eff (reactive :: Reactive | eff) {}
modifyRVar v f = do
  a <- readRVar v
  writeRVar v $ f a

------------------------------------------------------------------------------------------------

-- Type of computed (read-only) values
data Computed a = Computed 
  { read :: forall eff. Eff (reactive :: Reactive | eff) a
  , subscribe :: forall eff. (a -> Eff (reactive :: Reactive | eff) {}) -> Eff (reactive :: Reactive | eff) Subscription
  }

-- Convert an RVar to a computed value
toComputed :: forall a. RVar a -> Computed a
toComputed ref = Computed 
  { read: readRVar ref
  , subscribe: subscribe ref
  }

-- Convert an RArray to a computed array
toComputedArray :: forall a. RArray a -> Computed [a]
toComputedArray arr = Computed 
  { read: readRArray arr
  , subscribe: \f -> subscribeArray arr (\_ -> readRArray arr >>= f)
  }

instance bindComputed :: Prelude.Bind Computed where
  (>>=) (Computed a) f = Computed 
    { read: do
        x <- a.read
        case f x of
          Computed y -> y.read
    , subscribe: \ob -> do
        initial <- a.read 
        case f initial of 
          Computed b -> do
            s <- b.subscribe ob
            r <- unsafeRunRef $ newRef s
            aSub <- a.subscribe $ \a' -> do
              Subscription unsubscribe <- unsafeRunRef $ readRef r
              unsubscribe
              case f a' of
                Computed b' -> do
                  b'.read >>= ob
                  s' <- b'.subscribe ob
                  unsafeRunRef $ writeRef r s'
            return $ aSub <> Subscription (do
              Subscription unsubscribe <- unsafeRunRef $ readRef r
              unsubscribe)
    }

instance applicativeComputed :: Prelude.Applicative Computed where
  pure a = Computed 
    { read: pure a
    , subscribe: \_ -> pure mempty
    }

instance applyComputed :: Apply Computed where
  (<*>) (Computed f) (Computed x) = Computed
    { read: do
        f' <- f.read
        x' <- x.read
        return $ f' x'
    , subscribe: \ob -> do
        s1 <- f.subscribe $ \f' -> do
          x' <- x.read
          ob $ f' x'
        s2 <- x.subscribe $ \x' -> do
          f' <- f.read
          ob $ f' x'
        return $ s1 <> s2
    }

instance functorComputed :: Functor Computed where
  (<$>) = liftA1

instance monadComputed :: Monad Computed

-- Read a computed value
readComputed :: forall a eff. Computed a -> Eff (reactive :: Reactive | eff) a
readComputed (Computed c) = c.read

-- Subscribe for updates on a computed value
subscribeComputed :: forall a eff. Computed a -> (a -> Eff (reactive :: Reactive | eff) {}) -> Eff (reactive :: Reactive | eff) Subscription
subscribeComputed (Computed c) f = c.subscribe f

------------------------------------------------------------------------------------------------


