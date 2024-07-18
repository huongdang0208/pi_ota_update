## Run application as a service inside the raspberry pi system
- create a file in /etc/systemd/system/ota.service
```c
    [Unit]
    Description=Your Flask Application
    After=network.target

    [Service]
    User=pi
    WorkingDirectory=/home/thuhuong/ota_demo
    ExecStart=/home/thuhuong/ota_demo/env/bin/python /home/thuhuong/ota_demo/__init__.py
    Restart=always

    [Install]
    WantedBy=multi-user.target
```
- enable the service: sudo systemctl start ota.service
- install package: sudo apt-get install git rsync
## Sync between sources
`rsync` is a powerful tool for copying and synchronizing files and directories between two locations in a fast and efficient way. It stands for "remote sync" and is commonly used for backup and mirroring tasks.

### Key Features of `rsync`

1. **Incremental Transfers:** `rsync` only copies the differences between the source and the destination, which minimizes the amount of data transferred and speeds up the process.

2. **Local and Remote Syncing:** It can be used to sync files locally (on the same machine) or remotely (between different machines over a network).

3. **Preserves File Attributes:** It can preserve file permissions, modification times, symbolic links, and other attributes.

4. **Bandwidth Efficient:** It compresses data during transfer and reduces the amount of data sent over the network.

5. **Versatile Options:** `rsync` provides numerous options for customizing the sync process, such as excluding specific files, handling partial transfers, and running as a daemon.

### Basic Usage

The general syntax for `rsync` is:
```sh
rsync [options] source destination
```

#### Example Commands

- **Sync a Local Directory:**
  ```sh
  rsync -a /path/to/source/ /path/to/destination/
  ```
  - `-a`: Archive mode, which preserves permissions, timestamps, and symbolic links.

- **Sync to a Remote Server:**
  ```sh
  rsync -avz /path/to/source/ user@remote_host:/path/to/destination/
  ```
  - `-a`: Archive mode.
  - `-v`: Verbose, provides detailed output.
  - `-z`: Compress data during transfer.

- **Sync from a Remote Server:**
  ```sh
  rsync -avz user@remote_host:/path/to/source/ /path/to/destination/
  ```

- **Exclude Specific Files:**
  ```sh
  rsync -avz --exclude 'file_to_exclude' /path/to/source/ /path/to/destination/
  ```

### Explanation in the Context of OTA Updates

In the OTA update script provided, `rsync` is used to synchronize the updated application files from the `ota_updates` directory to the main application directory. This ensures that only the changes are copied, which makes the update process efficient.

#### Relevant Command from the Script:
```sh
rsync -a ~/ota_updates/ /path/to/your/application/
```
This command:
- Uses `-a` (archive mode) to preserve file attributes.
- Copies all updated files from `~/ota_updates/` to `/path/to/application/`.

## Create scripts
```c
    #!/bin/bash
    cd ~/ota_updates
    git fetch
    LOCAL=$(git rev-parse HEAD)
    REMOTE=$(git rev-parse @{u})
    if [ $LOCAL != $REMOTE ]; then
        echo "Repository is outdated. Updating…"
        git pull
        rsync -a ~/ota_updates/ /path/to/your/application/
        sudo systemctl restart your_application.service
    else
        echo "Repository is up to date."
    fi

```

## Run the scripts at specific time usign cron

`cron` is a time-based job scheduler in Unix-like operating systems. It enables users to schedule scripts or commands to run automatically at specified intervals or times. It's widely used for automating repetitive tasks such as system maintenance, backups, and monitoring.

### Key Features of `cron`

1. **Scheduling Tasks:** Allows scheduling tasks to run at specific times, dates, or intervals.
2. **Automated Execution:** Tasks run automatically without user intervention.
3. **Versatility:** Can schedule tasks to run daily, weekly, monthly, or at more complex intervals.
4. **User-Specific Cron Jobs:** Each user can have their own crontab (cron table) file to schedule their tasks.

### Basic Components

- **Cron Daemon (`crond`):** The background service that checks the crontab files and executes the scheduled tasks.
- **Crontab File:** The configuration file where users define their scheduled tasks. Each line in the file represents a cron job.

### Crontab Syntax

The crontab file format consists of five time-and-date fields followed by the command to be executed:
```plaintext
* * * * * command_to_run
- - - - -
| | | | |
| | | | +----- Day of the week (0 - 7) (Sunday is both 0 and 7)
| | | +------- Month (1 - 12)
| | +--------- Day of the month (1 - 31)
| +----------- Hour (0 - 23)
+------------- Minute (0 - 59)
```

### Example Crontab Entries

1. **Run a script every day at midnight:**
   ```plaintext
   0 0 * * * /path/to/script.sh
   ```

2. **Run a script every hour:**
   ```plaintext
   0 * * * * /path/to/script.sh
   ```

3. **Run a script every 5 minutes:**
   ```plaintext
   */5 * * * * /path/to/script.sh
   ```

4. **Run a script at 2:30 PM every day:**
   ```plaintext
   30 14 * * * /path/to/script.sh
   ```

### Managing Crontab Files

- **Edit Crontab File:**
  ```sh
  crontab -e
  ```
  This opens the crontab file in the default text editor.

- **List Crontab Entries:**
  ```sh
  crontab -l
  ```
  Displays the current user's crontab entries.

- **Remove Crontab File:**
  ```sh
  crontab -r
  ```
  Deletes the current user's crontab file.

### Example in the Context of OTA Updates

In your OTA update setup, you use `cron` to run the update script at regular intervals to check for updates and apply them if available. Here’s how it fits in:

1. **Creating the Crontab Entry:**
   Open the crontab file for editing:
   ```sh
   crontab -e
   ```

2. **Add the Update Script to Run Every Minute:**
   ```plaintext
   * * * * * /home/pi/ota_updates/update.sh
   ```
   This ensures the update script runs every minute to check for updates and apply them if needed.

