#!/bin/bash
rsync -e "ssh -i ~/.ssh/nid-rsync" -–progress -avz -–delete --exclude={/refDesk/,/tv-home/,index.html,indexSam.html,ex.txt,Vim-quickRef.pdf} /mnt/www/nginx/ notami@dbsaurer.com:/var/www/notami.us/html/

