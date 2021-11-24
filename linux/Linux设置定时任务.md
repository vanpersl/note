```sh
crontab -e
0 23 * * * ntpdate cn.pool.ntp.org >> /var/log/ntpdate.log
systemctl start crond
```
