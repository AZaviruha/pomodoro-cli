module Main where

import Control.Applicative
import Control.Concurrent.Suspend
import Control.Exception
import Control.Monad
import Data.Int (Int64)
import Data.List (intersperse)
import Options
import Text.Printf
import Sound.ALUT
import System.Console.ANSI
import System.Console.Readline
import System.Exit (exitFailure)
import System.IO

main = do
   -- Initialise ALUT and eat any ALUT-specific commandline flags.
   withProgNameAndArgs runALUT $ \progName args -> do 
      runCommand $ \opts args -> runMenuLoop opts
                  

data MainOptions = MainOptions { optAlarm :: FilePath
                               , optPomodoro :: Int64
                               , optShortBreak :: Int64
                               , optLongBreak :: Int64
                               } deriving (Show, Eq, Ord)
                 
instance Options MainOptions where
    defineOptions = pure MainOptions 
                <*> simpleOption "alarm" "./audio/alarm.wav"
                    "Path to alarm sound file"
                <*> simpleOption "pomodoro" 25
                    "Pomodoro length"
                <*> simpleOption "shortBreak" 5
                    "Short break length"
                <*> simpleOption "longBreak" 20
                    "Long break length"


data UserChoice = StartPomodoro 
                | StartShortBreak
                | StartLongBreak
                | Settings
                | Exit
                | UnknownChoice
                deriving (Show)


------------------------------------------------------------
-- Runs inifinite loop and waits for user input
------------------------------------------------------------
runMenuLoop :: MainOptions -> IO ()
runMenuLoop opts = runMenu
    where runMenu :: IO ()
          runMenu = do 
            clearScreen
            choice <- getMenuChoice 
            case choice of
              StartPomodoro   -> (startPomodoro (pomodoro * 60) fileName) >> runMenu
              StartShortBreak -> (startShortBreak (shortBreak * 60) fileName) >> runMenu
              StartLongBreak  -> (startLongBreak (longBreak * 60) fileName) >> runMenu
              Exit            -> return ()
              otherwise       -> runMenu
                                 
          fileName   = optAlarm opts
          pomodoro   = optPomodoro opts
          shortBreak = optShortBreak opts
          longBreak  = optLongBreak opts


------------------------------------------------------------
-- Draws menu and waits for user input
------------------------------------------------------------
getMenuChoice :: IO UserChoice
getMenuChoice = do
  putStrLn "##############################"
  putStrLn "####### Pomodoro Timer #######"
  putStrLn "##############################"
  putStrLn "#  1 - Start pomodoro timer  #"
  putStrLn "#  2 - Start short break     #"
  putStrLn "#  3 - Start long break      #"
  putStrLn "#  4 - Exit                  #"
  putStrLn "##############################"

  maybeLine <- readline "λ> "
  case maybeLine of
    Nothing     -> return Exit
    Just "exit" -> return Exit
    Just line   -> parseChoice line
  

------------------------------------------------------------
-- Tries to match user input to the one of main menu item.
-- Returns `UnknownChoice` if fails. 
------------------------------------------------------------
parseChoice :: String -> IO UserChoice
parseChoice s = 
    handle handler (return $ (read s :: UserChoice))
        where 
          handler :: NonTermination -> IO UserChoice
          handler e = return UnknownChoice

           
startPomodoro :: Int64 -> FilePath -> IO ()
startPomodoro s fileName = do
  putStrLn "Pomodoro started"
  startTimer s
  playFile fileName 5
  putStrLn "Pomodoro finished!"


startLongBreak :: Int64 -> FilePath -> IO ()
startLongBreak s fileName = do
  putStrLn "Long break started"
  startTimer s
  playFile fileName 5
  putStrLn "Long break finished!"


startShortBreak :: Int64 -> FilePath -> IO ()
startShortBreak s fileName = do
  putStrLn "Short break started"
  startTimer s
  playFile fileName 5
  putStrLn "Short break finished!"
           

startTimer :: Int64 -> IO ()
startTimer s = do runTimer $ s * 1000
  where runTimer :: Int64 -> IO ()
        runTimer ms = 
            if ms > 0 then 
                do clearLine
                   putStrLn $ formatTime ms 
                   cursorUpLine 1
                   suspend $ msDelay tick
                   runTimer $ ms - tick
            else do putStrLn "" 
                    return ()
                   
        tick = 1000 :: Int64

               
formatTime :: Int64 -> String
formatTime ms = let ss = ms `div` 1000 
                    mm = ss `div` 60 
                in printf "%02d:%02d" mm (ss - mm * 60)


------------------------------------------------------------
-- Plays sound from file during `s` seconds.
------------------------------------------------------------
playFile :: FilePath -> Float -> IO ()
playFile fileName s = do
   -- Create an AL buffer from the given sound file.
   buf <- createBuffer (File fileName)

   -- Generate a single source, attach the buffer to it and start playing.
   source <- genObjectName
   buffer source $= Just buf
   play [source]

   -- Normally nothing should go wrong above, but one never knows...
   errs <- get alErrors
   unless (null errs) $ do
      hPutStrLn stderr (concat (intersperse "," [ d | ALError _ d <- errs ]))
      exitFailure

   sleep s
   stop [source]


instance Read UserChoice where
    readsPrec _ v =
        case v of
          '1':xs    -> [(StartPomodoro, xs)]
          '2':xs    -> [(StartShortBreak, xs)]
          '3':xs    -> [(StartLongBreak, xs)]
          '4':xs    -> [(Exit, xs)]
          otherwise -> [(UnknownChoice, "")]
                  
                  
