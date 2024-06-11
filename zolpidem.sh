#!/bin/bash

readonly CPU_THRESHOLD="${CPU_THRESHOLD:-2}"
readonly DISK_IO_THRESHOLD="${DISK_IO_THRESHOLD:-1}"
readonly CHECK_INTERVAL="${CHECK_INTERVAL:-60}"
readonly IDLE_TIME="${IDLE_TIME:-900}"

idle_start_time=0

while true; do
  cpu_idle="$(mpstat 1 1 | awk '/Average:/ {print $NF}')"
  cpu_usage="$(echo "100 - $cpu_idle" | bc)"
  io_usage="$(iostat -dx 1 1 | awk '/sda/ {print $23}')"
  echo "Current CPU usage: $cpu_usage%, Disk I/O usage: $io_usage%" >&2

  if [ "$(echo "$cpu_usage < $CPU_THRESHOLD" | bc -l)" -ne 0 ] && \
    [ "$(echo "$io_usage < $DISK_IO_THRESHOLD" | bc -l)" -ne 0 ]; then

    if [ "$idle_start_time" -eq 0 ]; then
      idle_start_time="$(date +%s)"
    else
      current_time="$(date +%s)"
      idle_duration="$((current_time - idle_start_time))"
      echo "System idle for "$idle_duration" seconds." >&2

      if [ "$idle_duration" -ge "$IDLE_TIME" ]; then
        echo "Shutting down..." >&2
        poweroff
      fi
    fi
  else
    idle_start_time=0
  fi

  sleep "$CHECK_INTERVAL"
done
