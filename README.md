# pomodoro-cli
haskell newbie project

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
