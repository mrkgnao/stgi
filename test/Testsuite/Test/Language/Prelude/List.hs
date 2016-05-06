{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}

module Test.Language.Prelude.List (tests) where



import qualified Data.List                                            as L
import           Data.Monoid

import qualified Stg.Language.Prelude                                 as Stg
import           Stg.Parser

import           Test.Machine.Evaluate.TestTemplates.HaskellReference
import           Test.Orphans                                         ()
import           Test.Tasty



tests :: TestTree
tests = testGroup "List"
    [ stgSort
    , stgFilter
    , stgMap
    , stgZipWith ]

stgFilter :: TestTree
stgFilter = haskellReferenceTest HaskellReferenceTestSpec
    { testName = "filter"
    , maxSteps = 1024
    , successPredicate = "main" ===> [stg| () \n () -> Success () |]
    , source = \xs ->
           Stg.listOfNumbers "inputList" xs
        <> Stg.listOfNumbers "expectedResult" (filter (> 0) xs)
        <> Stg.int "zero" 0
        <> Stg.gt
        <> Stg.equals_List_Int
        <> Stg.filter
        <> [stgProgram|

        main = () \u () ->
            letrec
                positive = () \n (x) -> gt_Int (x, zero);
                filtered = (positive) \n () -> filter (positive, inputList)
            in case equals_List_Int (expectedResult, filtered) of
                True () -> Success ();
                wrong   -> TestFail (wrong)
        |] }

stgSort :: TestTree
stgSort = haskellReferenceTest HaskellReferenceTestSpec
    { testName = "sort"
    , maxSteps = 1024
    , successPredicate = "main" ===> [stg| () \n () -> Success () |]
    , source = \xs ->
           Stg.listOfNumbers "inputList" xs
        <> Stg.listOfNumbers "expectedResult" (L.sort xs)
        <> Stg.equals_List_Int
        <> Stg.sort
        <> [stgProgram|

        main = () \u () ->
            let sorted = () \u () -> sort (inputList)
            in case equals_List_Int (expectedResult, sorted) of
                True () -> Success ();
                wrong   -> TestFail (wrong)
        |] }

stgMap :: TestTree
stgMap = haskellReferenceTest HaskellReferenceTestSpec
    { testName = "map"
    , maxSteps = 1024
    , successPredicate = "main" ===> [stg| () \n () -> Success () |]
    , source = \(xs, offset) ->
           Stg.add
        <> Stg.map
        <> Stg.int "offset" offset
        <> Stg.listOfNumbers "inputList" xs
        <> Stg.listOfNumbers "expectedResult" (map (+offset) xs)
        <> Stg.equals_List_Int
        <> [stgProgram|

    main = () \u () ->
        letrec
            plusOffset = () \n (n) -> add (n, offset);
            actual = (plusOffset) \u () -> map (plusOffset, inputList)
        in case equals_List_Int (actual, expectedResult) of
            True () -> Success ();
            wrong   -> TestFail (wrong)
    |] }

stgZipWith :: TestTree
stgZipWith = haskellReferenceTest HaskellReferenceTestSpec
    { testName = "zipWith (+)"
    , maxSteps = 1024
    , successPredicate = "main" ===> [stg| () \n () -> Success () |]
    , source = \(list1, list2) ->
           Stg.equals_List_Int
        <> Stg.listOfNumbers "list1" list1
        <> Stg.listOfNumbers "list2" list2
        <> Stg.listOfNumbers "expectedResult" (zipWith (+) list1 list2)
        <> Stg.add
        <> Stg.zipWith
        <> [stgProgram|

    main = () \u () ->
        let zipped = () \n () -> zipWith (add, list1, list2)
        in case equals_List_Int (zipped, expectedResult) of
            True ()  -> Success ();
            wrong   -> TestFail (wrong)
    |] }
