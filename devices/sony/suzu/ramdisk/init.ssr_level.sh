#!/system/bin/sh
# Copyright (c) 2016 Sony Mobile Communications Inc.

ssr_str="$1"
ssr_array=($ssr_str)
build_variant=`getprop ro.build.type`

typeset -i i=0
subsys=`cat /sys/bus/msm_subsys/devices/subsys$i/name`
while [ "$subsys" != "" ]
do
   for num in "${!ssr_array[@]}"
   do
      if [ "$subsys" == ${ssr_array[$num]} ]; then
        echo "RELATED" > /sys/bus/msm_subsys/devices/subsys$i/restart_level
        break 1
      else
        echo "SYSTEM" > /sys/bus/msm_subsys/devices/subsys$i/restart_level
      fi
   done

   # SONY: ONLY_IN_DEBUG change modem wdog bite behavior to system crash
   if [ "$build_variant" != "user" ] && [ "$subsys" == "modem" ]; then
     echo "set" > /sys/bus/msm_subsys/devices/subsys$i/system_debug
   fi
   i=$i+1
   subsys=`cat /sys/bus/msm_subsys/devices/subsys$i/name`
done
