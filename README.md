# pistat

A live system dashboard for the Raspberry Pi, in one bash file. No installs, no dependencies.

Shows CPU temperature, load, RAM, disk, power/heat throttling warnings, IP and uptime, refreshed every 2 seconds. Works over SSH and on the Pi screen. Tested on DietPi style minimal installs (needs only bash, awk, tput).

## Run

    wget -O pistat.sh https://raw.githubusercontent.com/Greenisus1/pistat/main/pistat.sh
    bash pistat.sh

Press `q` to quit.

## Why

`htop` is great but does not show throttling or Pi temperature at a glance. This does, in about 50 lines you can read in a minute.

## License

MIT
