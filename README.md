# mail-my-ipv6-address
 
- Create .timer and .service files in /etc/systemd/user/
- Reload systemd daemons: $ systemctl --user daemon-reload
- Enable systemd timer: $ systemctl --user enable mail-my-public-ip.timer --now
- Create msmtp file in /etc/logrotate.d/
- Restart logrotate.service: # systemctl restart logrotate.service
- Start services if auto-login is disabled: $ loginctl enable-linger user