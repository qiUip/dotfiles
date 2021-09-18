# Prints an integer value of the temperature value directly from the sysfs path
# Use `sensors` to find preferred temperature source, then run
# $ for i in /sys/class/hwmon/hwmon*/temp*_input; do echo "$(<$(dirname $i)/name): $(cat ${i%_*}_label 2>/dev/null || echo $(basename ${i%_*})) $(readlink -f $i)"; done
# to find path to desired file.
# The location of the desired file is exported to a env variable to be used by the ctemp script for xmobar.  The selected sensor is "Package id" - change it to the desired sensor you with to use as needed.

export hwmon_id=$(for i in /sys/class/hwmon/hwmon*/temp*_input; do echo "$(<$(dirname $i)/name): $(cat ${i%_*}_label 2>/dev/null || echo $(basename ${i%_*})) $(readlink -f $i)"; done | awk '/Package id/{print $NF}')
