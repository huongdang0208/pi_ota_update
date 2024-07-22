#!/bin/bash

# Define variables
OTA_DIR=/home/thuhuong/pi_ota_update
APP_DIR=/home/thuhuong/ota_demo
VENV_DIR=/home/thuhuong/ota_demo/env

# Check for updates
cd $OTA_DIR
git fetch
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse @{u})

if [ $LOCAL != $REMOTE ]; then
    echo "Repository is outdated. Updating…"
    
    # Pull the latest changes
    git pull
    
    # Install any new dependencies
    $VENV_DIR/bin/pip install -r $OTA_DIR/requirements.txt
    
    # Sync the updated application files
    rsync -a $OTA_DIR/ $APP_DIR/
    
    # Restart the application service
    sudo systemctl restart your_application.service
else
    echo "Repository is up to date."
fi
