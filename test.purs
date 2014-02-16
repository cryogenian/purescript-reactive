module Main where

import Prelude
import Eff
import Reactive

main = do
  r <- newRVar 1
  subscribe r $ \a -> do
    Trace.print a
  modifyRVar r ((+) 1)
