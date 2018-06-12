Ubuntu代理设置
/etc/environment
```bash
no_proxy="localhost,127.0.0.1,172.*,10.*,122.119.*,*.abcd.com,*.aabb.com,*.abc.com,*.edg.com,*.efgh.com,.mycompany.com,.mycompany.net,*.x"
gsettings set org.gnome.system.proxy ignore-hosts "['127.0.0.1','localhost','192.168.*','172.26.*','172.27.*','10.*','122.119.*','*.mycompany.com','*.abcd.com','*.aabb.com','*.edg.com','*.abc.com','*.efgh.com','*.software.abcd.com','*.aabb.com','*.abcd.x','*.efgh.x','*.x']"
http_proxy="http://192.10.10.10:8080/"
ftp_proxy="ftp://192.10.10.10:8080/"
socks_proxy="socks://192.10.10.10:8080/"
https_proxy="https://192.10.10.10:8080/"
```
