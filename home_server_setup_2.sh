#! /bin/bash

username="$1"

# Remind user for the setup sequence
read -p 'This is part 2 of the setup if you have not run the first setup press "ctrl + c" or "ctrl + z" to stop else press enter...' </dev/tty

sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Create compose file for docker containers
echo '
Creating docker compose for adguardhome'
echo "version: '3.3'
services:
    adguardhome:
        container_name: adguardhome
        restart: unless-stopped
        volumes:
            - '/home/$username/server/configs/adguardhome/workdir:/opt/adguardhome/work'
            - '/home/$username/server/configs/adguardhome/confdir:/opt/adguardhome/conf'
        ports:
            - '53:53/tcp'
            - '53:53/udp'
            - '67:67/udp'
            - '69:69/udp'
            - '69:69/tcp'
            - '80:80/tcp'
            - '443:443/tcp'
            - '443:443/udp'
            - '3000:3000/tcp'
        image: adguard/adguardhome
    homarr:
        container_name: homarr
        image: ghcr.io/ajnart/homarr:latest
        restart: unless-stopped
        environment:
            - PUID=1000
            - PGID=1000
            - TZ=Asia/Kolkata
        volumes:
            - '/home/$username/server/configs/homarr:/app/data/configs'
            - '/home/$username/server/icons:/app/public/icons'
        ports:
            - '7575:7575'
    jackett:
        container_name: jackett
        image: linuxserver/jackett
        environment:
            - PUID=1000
            - PGID=1000
            - TZ=Asia/Kolkata
        volumes:
            - '/home/$username/server/configs/jackett:/config'
            - '/home/$username/server/torrents:/downloads'
        ports:
            - '9117:9117'
        restart: unless-stopped
    jellyfin:
        container_name: jellyfin
        image: ghcr.io/linuxserver/jellyfin
        environment:
            - PUID=1000
            - PGID=1000
            - TZ=Asia/Kolkata
        ports:
            - '8096:8096'
        volumes:
            - '/home/$username/server/configs/jellyfin:/config'
            - '/home/$username/server/media:/data/media'
        restart: unless-stopped
    lidarr:
        container_name: lidarr
        image: ghcr.io/linuxserver/lidarr
        environment:
            - PUID=1000
            - PGID=1000
            - TZ=Asia/Kolkata
        volumes:
            - '/home/$username/server/configs/lidarr:/config'
            - '/home/$username/server:/data'
        ports:
            - '8686:8686'
        restart: unless-stopped
    qflood:
        container_name: qflood
        image: hotio/qflood
        ports:
            - "8080:8080"
            - "3005:3000"
        environment:
            - PUID=1000
            - PGID=1000
            - UMASK=002
            - TZ=Asia/Kolkata
            - FLOOD_AUTH=false
        volumes:
            - '/home/$username/server/configs/qflood:/config'
            - '/home/$username/server/torrents:/data/torrents'
        restart: unless-stopped" > /home/$username/server/compose/docker-containers/docker-compose.yml
echo 'Docker containers compose created successfully!'

# Build and start those docker containers service
cd /home/$username/server/compose/docker-containers
# for folder in compose/*; do cd $folder && sudo docker compose up -d && cd /home/$username/server; done
echo "Docker containers are now up and running successfully!"
echo "You can follow the rest of the guide here: https://www.reddit.com/r/Piracy/comments/pqsomd/the_complete_guide_to_building_your_personal_self/"
echo "Good luck!"
