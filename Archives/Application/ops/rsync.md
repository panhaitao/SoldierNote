# 

# config

cp /usr/share/doc/rsync/examples/rsyncd.conf /etc/

```
[repo]
        comment = public archive
        path = /data/repo/
        use chroot = yes
#       max connections=10
        lock file = /var/lock/rsyncd
        read only = yes
        list = yes
        uid = nobody
        gid = nogroup
#       exclude = 
#       exclude from = 
#       include =
#       include from =
#       auth users = 
#       secrets file = /etc/rsyncd.secrets
        strict modes = yes
#       hosts allow =
#       hosts deny =
        ignore errors = no
        ignore nonreadable = yes
        transfer logging = no
#       log format = %t: host %h (%a) %o %f (%l bytes). Total %b bytes.
        timeout = 600
        refuse options = checksum dry-run
        dont compress = *.gz *.tgz *.zip *.z *.rpm *.deb *.iso *.bz2 *.tbz

```

# user

rsync -av --delete-after IP::repo /data/
 
