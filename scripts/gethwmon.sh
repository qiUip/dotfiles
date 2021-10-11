# Creates a enviroment variable for the path of the CPU temperature sensor.  This script should be added to /etc/profile.d to be executed upon startup.
# The selected sensor is "Package id" - change it to the desired sensor you with to use as needed.

export hwmon_id=$(for i in /sys/class/hwmon/hwmon*/temp*_input; do echo "$(<$(dirname $i)/name): $(cat ${i%_*}_label 2>/dev/null || echo $(basename ${i%_*})) $(readlink -f $i)"; done | awk '/Package id/{print $NF}')
