# How to use this image

Install Let's encrypt under /etc/letsencyrpt on the host. This certificates are being used in nginx/webdav container.

```console
$ docker run -d -p 443:443 -e USERNAME=ubuntu -e PASSWORD=foobar -v /etc/letsencrypt:/etc/letsencrypt -v /mnt/home:/home devany/webdav
```
This will start a webdav server listening on the default port of 80.
Then access it via `https://<yourdomain>` in a browser.

This server will serve files located in your /home folder

Image's supported volumes:
- `/home` - served directory


