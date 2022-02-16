#!/bin/bash

led=1
irled=29
filterA=28
filterB=27
exled=5

sensor=26

/usr/bin/gpio mode $led pwm
/usr/bin/gpio mode $irled out
/usr/bin/gpio mode $filterA out
/usr/bin/gpio mode $filterB out
/usr/bin/gpio mode $exled out

pwm=0

while :
do
    lux=`/usr/bin/curl -s http://192.168.1.9/LUX`
    human=`/usr/bin/gpio read $sensor`
    /usr/bin/gpio pwm $led $pwm
    
    if [ $lux -lt 20 ];then
        /usr/bin/gpio write $irled 1
        /usr/bin/gpio write $filterA 1
        /usr/bin/gpio write $filterB 0
        
        if [ $(date '+%H') -gt 16 ] || [ $human -eq 1 ];then
            /usr/bin/gpio write $exled 1
        else
            /usr/bin/gpio write $exled 0
        fi

        if [ $human -eq 1 ];then
            detect_time=`/bin/date +%s`
            if [ $pwm -lt 1000 ];then
                pwm=`expr $pwm + 20`
            else
                pwm=1000
            fi
        else
            now=`/bin/date +%s`
            if [ $pwm -gt 30 ];then
                if [ $now -gt `expr $detect_time + 180` ];then
                    pwm=`expr $pwm - 20`
                fi
            else
                pwm=30
            fi
        fi
    else
        /usr/bin/gpio write $irled 0
        /usr/bin/gpio write $filterA 0
        /usr/bin/gpio write $filterB 1
        pwm=0
    fi
done
