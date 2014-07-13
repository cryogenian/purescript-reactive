# Module Documentation

## Module Control.Reactive

### Types

    data Computed a where
      Computed :: { subscribe :: forall eff. (a -> Eff (reactive :: Reactive | eff) Unit) -> Eff (reactive :: Reactive | eff) Subscription, read :: forall eff. Eff (reactive :: Reactive | eff) a } -> Computed a

    data RArray :: * -> *

    data RArrayChange a where
      Inserted :: a -> Number -> RArrayChange a
      Updated :: a -> Number -> RArrayChange a
      Removed :: Number -> RArrayChange a

    data RVar :: * -> *

    data Reactive :: !

    data Subscription where
      Subscription :: forall eff. Eff (reactive :: Reactive | eff) Unit -> Subscription


### Type Class Instances

    instance applicativeComputed :: Prelude.Applicative Computed

    instance applyComputed :: Apply Computed

    instance bindComputed :: Prelude.Bind Computed

    instance functorComputed :: Functor Computed

    instance monadComputed :: Monad Computed

    instance monoidSubscription :: Data.Monoid.Monoid Subscription

    instance semigroupSubscription :: Semigroup Subscription

    instance showArrayChange :: (Prelude.Show a) => Prelude.Show (RArrayChange a)


### Values

    insertRArray :: forall a eff. RArray a -> a -> Number -> Eff (reactive :: Reactive | eff) Unit

    modifyRVar :: forall a eff. RVar a -> (a -> a) -> Eff (reactive :: Reactive | eff) Unit

    newRArray :: forall a eff. Eff (reactive :: Reactive | eff) (RArray a)

    newRVar :: forall a eff. a -> Eff (reactive :: Reactive | eff) (RVar a)

    peekRArray :: forall a eff. RArray a -> Number -> Eff (reactive :: Reactive | eff) a

    readComputed :: forall a eff. Computed a -> Eff (reactive :: Reactive | eff) a

    readRArray :: forall a eff. RArray a -> Eff (reactive :: Reactive | eff) [a]

    readRVar :: forall a eff. RVar a -> Eff (reactive :: Reactive | eff) a

    removeRArray :: forall a eff. RArray a -> Number -> Eff (reactive :: Reactive | eff) a

    subscribe :: forall a eff. RVar a -> (a -> Eff (reactive :: Reactive | eff) Unit) -> Eff (reactive :: Reactive | eff) Subscription

    subscribeArray :: forall a eff. RArray a -> (RArrayChange a -> Eff (reactive :: Reactive | eff) Unit) -> Eff (reactive :: Reactive | eff) Subscription

    subscribeComputed :: forall a eff. Computed a -> (a -> Eff (reactive :: Reactive | eff) Unit) -> Eff (reactive :: Reactive | eff) Subscription

    toComputed :: forall a. RVar a -> Computed a

    toComputedArray :: forall a. RArray a -> Computed [a]

    updateRArray :: forall a eff. RArray a -> a -> Number -> Eff (reactive :: Reactive | eff) Unit

    writeRVar :: forall a eff. RVar a -> a -> Eff (reactive :: Reactive | eff) Unit