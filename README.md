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