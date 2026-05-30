#!/bin/env/bash

date=(
  icon.drawing=off                   
  label.font="$FONT:Semibold:9"      
  label.padding_right=4                   
  y_offset=5                         
  width=0                            
  update_freq=60                     
  script='sketchybar --set $NAME label="$(date "+%a, %b %d")"'
  click_script="open -a Calendar.app"
)

clock=(
  "${menu_defaults[@]}"
  icon.drawing=off          
  label.font="$FONT:Bold:12" 
  label.padding_right=4           
  y_offset=-3            
  update_freq=10            
  popup.align=right
  script="$PLUGIN_DIR/nextevent.sh"
  click_script="sketchybar --set clock popup.drawing=toggle; open -a Calendar.app"
)

calendar_item=(
  label.width=180
  padding_left=0
  padding_right=0
  label.align=left
  label.padding_left=0
  label.padding_right=0
  icon.drawing=off
)

sketchybar                                      \
  --add item date right                         \
  --set date "${date[@]}"                       \
  --subscribe date system_woke                  \
                   mouse.entered                \
                   mouse.exited                 \
                   mouse.exited.global          \
  --add item date.details popup.date            \
  --set date.details "${menu_item_defaults[@]}" \
                                                \
  --add item clock right                        \
  --set clock "${clock[@]}"                     \
  --subscribe clock system_woke                 \
                    mouse.entered               \
                    mouse.exited                \
                    mouse.exited.global         \
  --add item clock.next_event popup.clock          \
  --set clock.next_event "${menu_item_defaults[@]}" icon.drawing=off label.padding_left=0 label.max_chars=22 \

# IFS=$'\n' read -d '' -r -a lines <<< "$(gcal --starting-day=1 | tail -n +3 | sed 's/< \([0-9]*\)>/ [\1]/g')"

for ((index=0; index<${#lines[@]}-1; index++))
do
    sketchybar --add item cal.$index popup.clock --set cal.$index "${menu_item_defaults[@]}" "${calendar_item[@]}" label="${lines[index]}"
done
