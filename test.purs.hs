module Main where

import Prelude
import Eff
import Reactive

main = do
  r1 <- newRVar 1
  r2 <- newRVar 2
  let c = (+) <$> toComputed r1 <*> toComputed r2
  subscribeComputed c $ \a -> do
    Trace.print a
  modifyRVar r1 ((+) 1)
  modifyRVar r2 ((+) 1)
