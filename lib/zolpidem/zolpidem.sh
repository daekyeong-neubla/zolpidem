#!/bin/bash

readonly CHECK_INTERVAL="${CHECK_INTERVAL:-60}"
readonly IDLE_TIME="${IDLE_TIME:-900}"

readonly idle_dir="$(dirname "$(realpath "$0")")/idle.d"

main() {
  local idle_start_time=0

  while true; do
    if are_all_idle; then
      if [ "$idle_start_time" -eq 0 ]; then
        idle_start_time="$(date +%s)"
      else
        local current_time="$(date +%s)"
        local idle_duration="$((current_time - idle_start_time))"
        echo "System idle for "$idle_duration" seconds." >&2

        if [ "$idle_duration" -ge "$IDLE_TIME" ]; then
          echo "Shutting down..." >&2
          poweroff
          return 0
        fi
      fi
    else
      idle_start_time=0
    fi

    sleep "$CHECK_INTERVAL"
  done
  return 1
}

are_all_idle() {
  pushd "$idle_dir" >/dev/null || return 1
    run-parts . --exit-on-error
    local res=$?
  popd >/dev/null
  return "$res"
}

main "$@"
