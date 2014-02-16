module Reactive where

import Prelude
import Eff
import Random
import Arrays

-- Reactive variables
foreign import data RVar :: * -> *

-- Reactive collections
foreign import data RArray :: * -> *

-- The effect of using reactive variables
foreign import data Reactive :: !

-- Create a new reactive variable
foreign import newRVar 
  "function newRVar(a) {\
  \  return function() {\
  \    return {\
  \      value: a,\
  \      onUpdate: function () {\
  \        return function () {\
  \        };\
  \      }\
  \    };\
  \  };\
  \}" :: forall a eff. a -> Eff (reactive :: Reactive | eff) (RVar a)

-- Create a new reactive collection
foreign import newRArray 
  "function newRArray() {\
  \  return {\
  \    values: [],\
  \    onUpdate: function() {\
  \      return function() {\
  \      };\
  \    },\
  \  };\
  \}" :: forall a eff. Eff (reactive :: Reactive | eff) (RArray a)

-- Read the value of a reactive variable
foreign import readRVar 
  "function readRVar(v) {\
  \  return function() {\
  \    return v.value;\
  \  };\
  \}" :: forall a eff. RVar a -> Eff (reactive :: Reactive | eff) a

-- Read the values inside a reactive collection
foreign import readRArray 
  "function readRArray(v) {\
  \  return function() {\
  \    return v.values;\
  \  };\
  \}" :: forall a eff. RArray a -> Eff (reactive :: Reactive | eff) [a]

-- Write the value of a reactive variable
foreign import writeRVar
  "function writeRVar(v) {\
  \  return function (a) {\
  \    return function() {\
  \      v.value = a;\
  \      v.onUpdate(a)();\
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
  \  return function (a) {\
  \    return function(i) {\
  \      return function() {\
  \        arr.values.splice(i, 0, a);\
  \        arr.onUpdate(_ps.Reactive.Inserted(a)(i))();\
  \      };\
  \    };\
  \  };\
  \}" :: forall a eff. RArray a -> a -> Number -> Eff (reactive :: Reactive | eff) {}

-- Remove a value from a reactive collection
foreign import removeRArray 
  "function removeRArray(arr) {\
  \  return function(i) {\
  \    return function() {\
  \      arr.values.splice(i, 1);\
  \      arr.onUpdate(_ps.Reactive.Removed(i))();\
  \    };\
  \  };\
  \}":: forall a eff. RArray a -> Number -> Eff (reactive :: Reactive | eff) a

-- Update a value in a reactive collection
foreign import updateRArray 
  "function updateRArray(arr) {\
  \  return function (a) {\
  \    return function(i) {\
  \      return function() {\
  \        arr.values[i] = a;\
  \        arr.onUpdate(_ps.Reactive.Updated(a)(i))();\
  \      };\
  \    };\
  \  };\
  \}" :: forall a eff. RArray a -> a -> Number -> Eff (reactive :: Reactive | eff) {}

-- Subscribe for updates on an RVar 
foreign import subscribe 
  "function subscribe(v) {\
  \  return function(f) {\
  \    return function() {\
  \      var onUpdate = v.onUpdate;\
  \      v.onUpdate = function(a) {\
  \        return function() {\
  \          onUpdate(a)();\
  \          f(a)();\
  \        };\
  \      };\
  \    };\
  \  };\
  \}" :: forall a eff. RVar a -> (a -> Eff eff {}) -> Eff (reactive :: Reactive | eff) {}

data RArrayChange a
  = Inserted a Number
  | Updated a Number
  | Removed Number

instance (Prelude.Show a) => Prelude.Show (RArrayChange a) where
  show (Inserted a n) = "Inserted " ++ show a ++ " at " ++ show n
  show (Updated a n) = "Updated " ++ show n ++ " to " ++ show a
  show (Removed n) = "Removed at index " ++ show n

-- Subscribe for updates on an RArray
foreign import subscribeArray 
  "function subscribe(arr) {\
  \  return function(f) {\
  \    return function() {\
  \      var onUpdate = arr.onUpdate;\
  \      arr.onUpdate = function(change) {\
  \        return function() {\
  \          onUpdate(change)();\
  \          f(change)();\
  \        };\
  \      };\
  \    };\
  \  };\
  \" :: forall a eff. RArray a -> (RArrayChange a -> Eff eff {}) -> Eff (reactive :: Reactive | eff) {}

------------------------------------------------------------------------------------------------

modifyRVar :: forall a eff. RVar a -> (a -> a) -> Eff (reactive :: Reactive | eff) {}
modifyRVar v f = do
  a <- readRVar v
  writeRVar v $ f a

------------------------------------------------------------------------------------------------


