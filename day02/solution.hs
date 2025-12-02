import Control.Monad
import Data.Char
import Data.List
import Data.Set qualified as Set
import Debug.Trace
import System.IO
import Prelude

-------------------
-- Input parsing --
-------------------

split "" = []
split s = w : split s''
  where
    (w, s') = break (== ',') s
    s'' = drop 1 s'

parseRange s = (a, b)
  where
    (a', b') = break (== '-') s
    a = read a' :: Integer
    b = read (drop 1 b') :: Integer

parseContent = map f . split
  where
    f = parseRange . filter (not . isSpace)

readInput = do
  handle <- openFile "input.txt" ReadMode
  content <- hGetContents handle
  let ranges = parseContent content
  return ranges

--------------------
-- Business logic --
--------------------

both f (a, b) = (f a, f b)

insertAll = foldl (flip Set.insert)

len = (+ 1) . floor . logBase 10 . fromIntegral

mkDelta _ 0 = 0
mkDelta len times = n + mkDelta len (times - 1)
  where
    n = 10 ^ (len * (times - 1))

getInvalidIdsOfLen :: Integer -> Integer -> Integer -> Integer -> [Integer]
getInvalidIdsOfLen a b patLen times = aux init
  where
    delta = mkDelta patLen times
    a' = max a ((10 ^ (patLen - 1)) * delta)
    b' = min b ((10 ^ patLen) * delta - 1)
    init = ceiling ((fromIntegral a') / (fromIntegral delta)) * delta
    aux n
      | n > b' = []
      | otherwise = n : aux (n + delta)

getInvalidIds :: (Integer, Integer) -> (Set.Set Integer, Set.Set Integer)
getInvalidIds (a, b) = aux init (bLen `div` 2) (bLen - aLen)
  where
    init = (Set.empty, Set.empty)
    aLen = len a
    bLen = len b
    aux acc 0 _ = acc
    aux acc patLen (-1) = aux acc (patLen - 1) (bLen - aLen)
    aux (acc1, acc2) patLen lenOffset = aux (acc1', acc2') patLen (lenOffset - 1)
      where
        c = if m == 0 && d > 1 then getInvalidIdsOfLen a b patLen d else []
        c' = if d == 2 then c else []
        acc1' = insertAll acc1 c'
        acc2' = insertAll acc2 c
        (d, m) = (aLen + lenOffset) `divMod` patLen

main = do
  ranges <- readInput
  let all = map getInvalidIds ranges
  let (total, total') = both (sum . (foldl Set.union Set.empty)) $ unzip all
  putStrLn $ show total
  putStrLn $ show total'
