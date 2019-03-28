# Active Directory Domain Controller by SAMBA in Docker

# important notification
* The release lifetime for ubuntu 18.04: April 2023
* the release lifetime for samba 4.10.0: TBA

# How to start
```
git clone https://github.com/soga-denken/samba-ad-dc.git
cd samba-ad-dc
cp composes/docker-compose.yml.example1 ./docker-compose.yml
vim .env
echo "Yourpass" > AdminPassSecret
docker-compose build
docker-compose up -d
```

## Password
If you prefer to keep samba admin pass in secret location, edit the following.
```
secrets:
  AdminPassSecret:
    file: ./AdminPassSecret
```

# License
This repository is licensed under MIT license. Please use this with your own risk.

## Disclaimer
- This work was prepared or accomplished by soga-denken in his personal capacity. The works are the author's own and do not reflect the view  of his employer.
- Except as contained in this notice, the name of the soga-denken and his employer's name shall not be used in advertising or otherwise to promote the sale, use or other dealings in this code without prior written authorization from soga-denken.

# What's unique in this docker-powered domain control?
- built from the source code
- easy to modify the code
- license is clearly stated. This is the reason why I built my own Dockerfile.
- the latest samba image. I love new version. If new samba is released, then Dockerfile will be modified.

# .env file
Parameters to build and run a docker image is controlled by .env file. 
For the details, please read .env file.

# volume
- /etc/localtime:/etc/localtime:ro - use local time in the container
- ./samba/backup:/backup - backups are saved
- ./samba/keys:/keys - self-signed certificate is saved
- ./samba/config:/etc/samba/ - smb.conf is here
- ./samba/data:/var/lib/samba - samba data

## backup
From SAMBA 4.10, samba-backup was deprecated. Instead, use the following command

`docker-compose exec samba backup`

Then, backed up files are stored in ./samba/backup. This run_backup script simply wraps `samba-tool domain backup offline --targetdir=/backup`. Note that offline does not mean you have to stop SAMBA. Instead, it means the backup is done locally. Non-offline backup can save a remote DC data.

To restore or to understand the details, please check the original [manual](https://wiki.samba.org/index.php/Back_up_and_Restoring_a_Samba_AD_DC#Testing_the_backup_restoration).

## TODO
- update the image to ubuntu 20.04 when released
- write a script to join an existing domain
- enable multi site domain control
- log file for supervisord
- log file for samba
