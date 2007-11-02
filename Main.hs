module Main where

import Tokens
import Lexer
import Parser

import Abstract
import ScopeChecker
import TypeChecker
import Value

import System

import System.IO (stdout, hSetBuffering, BufferMode(..))


main :: IO ()
main = do
  hSetBuffering stdout NoBuffering
  putStrLn $ "***** MiniAgda v1.0 *****"
  args <- getArgs
  file <- readFile (args !! 0)
  t <- return $ alexScanTokens file 
  ast <- return $ parse t
  putStrLn ("--- scope checking ---")
  ast2 <- return $ doScopeCheck ast
  putStrLn ("--- type checking ---")
  tc <- doTypeCheck ast2
  case tc of
    Nothing -> return ()
    Just sig -> do putStrLn "--- evaluating constants ---" 
                   showAll sig ast2
  

-- all constants
allConst :: Signature -> [Declaration] -> [(Name,Clos)]
allConst sig [] = []
allConst sig (decl:xs) =
    case decl of
      (ConstDecl True (TypeSig n t) e) -> 
          let c = VClos [] e in
          (n,c):(allConst sig xs)
      _ -> allConst sig xs 


showAll :: Signature -> [Declaration] -> IO ()
showAll sig decl = let ls = map (showConst sig) (allConst sig decl) in
                  sequence_ (map putStrLn ls)

showConst :: Signature -> (Name,Clos) -> String
showConst sig (n,v) = let Right (str,_) = whnfClos sig v 
                      in
                        n ++ " evaluates to " ++ str

doTypeCheck :: [Declaration] -> IO (Maybe Signature)
doTypeCheck decl = do let k = typeCheck decl
                      case k of
                        Left err -> do putStrLn $ "error during typechecking:\n" ++ show err
                                       return Nothing
                        Right (_,sig) -> do return $ Just sig

doScopeCheck :: [Declaration] -> [Declaration]
doScopeCheck decl = let k = scopeCheck decl 
                    in
                      case k of
                        Left err -> error $ "scope check error: " ++ err
                        Right (decl',_) -> decl'