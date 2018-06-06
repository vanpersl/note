sudo gedit  /etc/environment



加入如下几行

代理
```sh
#config for http proxy
export http_proxy=http://XXX.XXX.XXX.XXX:XXXX
export https_proxy=http://XXX.XXX.XXX.XXX:XXXX
export ftp_proxy=http://XXX.XXX.XXX.XXX:XXXX
```


例外：
```sh
# for common

no_proxy="127.0.0.1, localhost, 172.26.*, 172.25.6.66, *.google.*, *.facebook.com, 192.168.*, developer.android.com"
```
每个例外用【,】间隔

```sh
# for chrome firefox

gsettings set org.gnome.system.proxy ignore-hosts "['127.0.0.1', 'localhost', '172.26.*' ]"
```

```sh
# for apt-get

sudo gedit /etc/apt/apt.conf

Acquire::http:proxy "http://proxy_address:proxy_port"

Acquire::https:proxy "https://proxy_address:proxy_port"

Acquire::ftp:proxy "ftp://proxy_address:proxy_port"

Acquire::socks:proxy "socks://proxy_address:proxy_port"
```


环境变量即时生效

source /etc/environment



查看环境变量设置

export
