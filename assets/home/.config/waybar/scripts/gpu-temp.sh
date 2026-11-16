#!/usr/bin/env bash

temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null | head -n1)

if [ -z "$temp" ]; then
  echo '{"text":"GPU N/A","tooltip":"GPU temperature unavailable","class":"unavailable"}'
else
  echo "{\"text\":\"GPU ${temp}°C\",\"tooltip\":\"GPU: ${temp}°C\",\"class\":\"gpu\"}"
fi
