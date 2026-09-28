#!/bin/bash
URL="https://seguimientointeligente.lovable.app/api/public/cameras/upload"
TOKEN="YOUR_CAMERA_TOKEN"
DIR=/tmp/cam; mkdir -p $DIR

# 1) Record continuously into 4 s clips (runs in background)
ffmpeg -loglevel error -i /home/bio/camera-upload-low/stream.m3u8 -c copy -an \
  -f segment -segment_time 4 -reset_timestamps 1 \
  -segment_format_options movflags=+faststart \
  -strftime 1 "$DIR/clip_%s.mp4" &

# 2) Upload finished clips (everything except the one still being written)
while true; do
  for f in $(ls -1t $DIR/clip_*.mp4 2>/dev/null | tail -n +2 | sort); do
    curl -s -m 20 -X POST "$URL" -H "Authorization: Bearer $TOKEN" \
      -F "file=@$f;type=video/mp4" -F "duration=4" | grep -q '"ok":true' && rm -f "$f"
  done
  ls -1t $DIR/clip_*.mp4 2>/dev/null | tail -n +20 | xargs -r rm -f   # cap backlog
  sleep 1
done

