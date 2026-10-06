#!/usr/bin/env bash
# pistat - live Raspberry Pi dashboard in your terminal. Pure bash, no installs.
# Shows CPU temp, load, RAM, disk, throttling flags, IP, uptime. q to quit.
bar() { # percent width
  local p=$1 w=${2:-20} f i s=""
  f=$(( p * w / 100 )); [ "$f" -gt "$w" ] && f=$w
  for ((i=0;i<w;i++)); do if [ $i -lt $f ]; then s+="#"; else s+="-"; fi; done
  printf '[%s] %3d%%' "$s" "$p"
}
cleanup() { tput cnorm; tput rmcup; exit 0; }
trap cleanup INT TERM EXIT
tput smcup; tput civis
while true; do
  t=0; [ -r /sys/class/thermal/thermal_zone0/temp ] && t=$(( $(cat /sys/class/thermal/thermal_zone0/temp) / 1000 ))
  read -r l1 l5 l15 _ < /proc/loadavg
  cores=$(grep -c '^processor' /proc/cpuinfo)
  mt=$(awk '/MemTotal/{print $2}' /proc/meminfo); ma=$(awk '/MemAvailable/{print $2}' /proc/meminfo)
  mp=$(( (mt - ma) * 100 / mt ))
  dp=$(df / | awk 'NR==2{gsub("%","",$5);print $5}')
  lp=$(awk -v l="$l1" -v c="$cores" 'BEGIN{p=l*100/c; if(p>100)p=100; printf "%d",p}')
  tp=$(( t * 100 / 85 )); [ $tp -gt 100 ] && tp=100
  up=$(awk '{d=int($1/86400);h=int($1%86400/3600);m=int($1%3600/60);printf "%dd %dh %dm",d,h,m}' /proc/uptime)
  ip=$(hostname -I 2>/dev/null | awk '{print $1}')
  th="n/a"
  if command -v vcgencmd >/dev/null 2>&1; then
    v=$(vcgencmd get_throttled 2>/dev/null | cut -d= -f2)
    case "$v" in 0x0) th="OK";; "") th="n/a";; *) th="WARNING $v (power or heat)";; esac
  fi
  tput cup 0 0; tput ed
  printf 'PISTAT   %s   up %s\n\n' "$(hostname)" "$up"
  printf 'Temp  %s  %s C\n' "$(bar $tp)" "$t"
  printf 'CPU   %s  load %s %s %s (%s cores)\n' "$(bar $lp)" "$l1" "$l5" "$l15" "$cores"
  printf 'RAM   %s  %s / %s MB\n' "$(bar $mp)" "$(( (mt-ma)/1024 ))" "$(( mt/1024 ))"
  printf 'Disk  %s\n' "$(bar $dp)"
  printf '\nThrottle: %s\nIP: %s\n\nq = quit\n' "$th" "${ip:-none}"
  read -rsn1 -t 2 k && [ "$k" = q ] && break
done
