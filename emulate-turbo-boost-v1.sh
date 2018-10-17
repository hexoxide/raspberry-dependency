#!/bin/bash
MODE=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
while true
do
        TEMP=$(cat /sys/class/thermal/thermal_zone0/temp)
        echo "$TEMP"
        if ((TEMP > 71000)) && [ "$MODE" == "performance" ]; then
                MODE="powersave"
                echo "powersave" | tee /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor
        fi
        if ((TEMP < 61000)) && [ "$MODE" == "powersave" ]; then
                MODE="performance"
                echo "performance" | tee /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor
        fi
        sleep 5
done