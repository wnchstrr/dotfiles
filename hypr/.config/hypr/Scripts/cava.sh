#!/bin/bash
bar="▁▂▃▄▅▆▇█"
dict="s/;//g"
i=0
while [ $i -lt 8 ]; do
    dict="${dict};s/$i/${bar:$i:1}/g"
    i=$((i+1))
done
cava -p ~/.config/cava/waybar_config | while read -r line; do
    echo "${line//;/}" | sed "$dict"
done
