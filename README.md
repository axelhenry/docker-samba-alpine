## Running container
docker run -d --net=host -p 137-139:137-139 -p 445:445 -v /mnt/Storage/Torrents:/shared -v /docker/configs/samba/samba.torrents:/config --name samba.torrents axelhenry/docker-samba-alpine

