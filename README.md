# Sant Roc Camera Video Pipeline

Raspberry Pi based Dahua camera video pipeline for near-live playback through the Lovable application.

## Architecture

Dahua Camera
-> Raspberry Pi
-> HLS rolling buffer
-> 4-second MP4 clips
-> HTTPS upload
-> Lovable application

## Main Components

### Dahua Camera
- Main stream: H.264, 1280x720, 30 FPS
- Substream: H.264, 352x240, 15 FPS
- Substream bitrate: 256 Kb/s
- Channel: 1

### Raspberry Pi Services

The following systemd services are used:

- `camera-live.service`
  - Reads the Dahua main RTSP stream
  - Creates a rolling HLS buffer
  - Output folder: `/home/bio/camera-live`

- `camera-web.service`
  - Serves the main HLS folder over local HTTP
  - Port: `8091`

- `camera-upload-low.service`
  - Reads the Dahua low-bitrate substream
  - Creates a small HLS buffer for uploads
  - Output folder: `/home/bio/camera-upload-low`

- `camera-uploader.service`
  - Runs `/home/bio/camera-uploader.sh`
  - Creates 4-second MP4 clips
  - Uploads clips to the Lovable camera API

## Repository Structure

```text
sant-roc-camera/
├── README.md
├── camera-uploader.sh
├── .env.example
├── .gitignore
└── systemd/
    ├── camera-live.service
    ├── camera-web.service
    ├── camera-upload-low.service
    └── camera-uploader.service

Configuration
Create the real environment file outside Git:
cp .env.example .env

Example:
CAM_HOST=192.168.1.20
CAM_USER=admin
CAM_PASS=CHANGE_ME
CAM_CHANNEL=1

Do not commit the real .env file.
The Lovable upload token must also remain private and must not be committed to GitHub.
Useful Commands
Check all camera services:
systemctl is-active camera-live.service camera-web.service camera-upload-low.service camera-uploader.service

Restart all services:
sudo systemctl restart camera-live.service camera-web.service camera-upload-low.service camera-uploader.service

Check uploader status:
systemctl status camera-uploader.service

View uploader logs:
journalctl -u camera-uploader.service -f

Check video files:
ls -lh /home/bio/camera-live
ls -lh /home/bio/camera-upload-low
ls -lh /tmp/cam

Automatic Startup
The services are enabled with systemd and automatically start after Raspberry Pi reboot or power recovery.
Remote Administration
Remote Raspberry Pi administration is available through Tailscale.
Example:
