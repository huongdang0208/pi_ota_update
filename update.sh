#!/bin/bash

# Define variables
OTA_DIR=/home/thuhuong/pi_ota_update
APP_DIR=/home/thuhuong/ota_demo
VENV_DIR=/home/thuhuong/ota_demo/env
LOG_FILE=/home/thuhuong/ota_update.log
BACKUP_DIR=/home/thuhuong/ota_backup/pi_ota_update

# Log function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >> $LOG_FILE
}

# Backup current application state
backup() {
    log "Creating backup..."
    rsync -a --delete $APP_DIR/ $BACKUP_DIR/ >> $LOG_FILE 2>&1
    if [ $? -ne 0 ]; then
        log "Error: Backup failed."
        exit 1
    fi
    log "Backup created successfully."
}

# Rollback functions
rollback() {
    log "Rolling back to previous version..."
    rsync -a --delete $BACKUP_DIR/ $APP_DIR/ >> $LOG_FILE 2>&1
    if [ $? -ne 0 ]; then
        log "Error: Rollback failed."
        exit 1
    fi

    # Restart the application service
    sudo systemctl restart ota_demo.service >> $LOG_FILE 2>&1
    if [ $? -ne 0 ]; then
        log "Error: Failed to restart application service during rollback."
        exit 1
    fi

    log "Rollback completed successfully."
}

# Check for updates
cd $OTA_DIR || exit
git fetch
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse @{u})

if [ "$LOCAL" != "$REMOTE" ]; then
    log "Repository is outdated. Updating…"

    # Backup current state
    backup

    # Pull the latest changes
    git pull >> $LOG_FILE 2>&1
    if [ $? -ne 0 ]; then
        log "Error: Git pull failed."
        rollback
        exit 1
    fi

    # Install any new dependencies
    $VENV_DIR/bin/pip install -r $OTA_DIR/requirements.txt >> $LOG_FILE 2>&1
    if [ $? -ne 0 ]; then
        log "Error: Installing dependencies failed."
        rollback
        exit 1
    fi

    # Sync the updated application files
    rsync -a --delete $OTA_DIR/ $APP_DIR/ >> $LOG_FILE 2>&1
    if [ $? -ne 0 ]; then
        log "Error: Rsync failed."
        rollback
        exit 1
    fi

    # Restart the application service
    sudo systemctl restart ota_demo.service >> $LOG_FILE 2>&1
    if [ $? -ne 0 ]; then
        log "Error: Failed to restart application service."
        rollback
        exit 1
    fi

    log "Update completed successfully."
else
    log "Repository is up to date."
fi
