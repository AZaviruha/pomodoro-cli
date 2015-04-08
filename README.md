# pomodoro-cli
haskell newbie project

## How to build
```shell
-- OpenGL:   
sudo apt-get install libglu1-mesa-dev freeglut3-dev mesa-common-dev

-- OpenAL:  
sudo apt-get install libopenal1 libopenal-dev

-- ALUT:     
sudo apt-get install libalut0 libalut-dev

-- Cabal dependencies
cabal sandbox init
cabal install
cabal configure
cabal build
```

## How it looks like
```shell
> pomodoro-cli --alarm=./.../my-alarm.wav

############################## 
####### Pomodoro Timer ####### 
############################## 
#  1 - Start pomodoro timer  # 
#  2 - Start short break     # 
#  3 - Start long break      # 
#  4 - Exit                  # 
############################## 
λ> 1                           
Pomodoro started               
24:59                          
```

## Help
```shell
> pomodoro-cli -h

Help Options:                   
  -h, --help                    
    Show option summary.        
  --help-all                    
    Show all help options.      
                                
Application Options:            
  --alarm :: text               
    Path to alarm sound file    
    default: "./audio/alarm.wav"
  --pomodoro :: int64           
    Pomodoro length             
    default: 25                 
  --shortBreak :: int64         
    Short break length          
    default: 5                  
  --longBreak :: int64          
    Long break length           
    default: 20                 

```
