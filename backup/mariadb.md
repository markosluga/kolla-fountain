# Backup mariadb and restore

## Backup

### Enable backups via globals.yml:

`enable_mariabackup: "yes"`

* To perform a full backup, run the following command:

`kolla-ansible -i INVENTORY mariadb_backup`

## Restore

### Restoring a full backup

Create a restore container:

`sudo docker run --rm -it --volumes-from mariadb --name dbrestore --volume mariadb_backup:/backup kolla/ubuntu-binary-mariadb-server:wallaby /bin/bash`

Run the restore commands in the restore container:

`
cd /backup
rm -rf /backup/restore
mkdir -p /backup/restore/full
gunzip mysqlbackup-01-11-2021-1635773719.qp.xbc.xbs.gz
mbstream -x -C /backup/restore/full/ <  mysqlbackup-01-11-2021-1635773719.qp.xbc.xbs
mariabackup --prepare --target-dir /backup/restore/full
exit
`
Stop the restore container:

`sudo docker stop mariadb`

Start up a new mariadb container:

`sudo docker run --rm -it --volumes-from mariadb --name dbrestore --volume mariadb_backup:/backup kolla/ubuntu-binary-mariadb-server:wallaby /bin/bash`

Restore mariadb to the new container:

`
rm -rf /var/lib/mysql/*
rm -rf /var/lib/mysql/\.[^\.]*
mariabackup --copy-back --target-dir /backup/restore/full
exit
`
Now start mariadb:

`sudo docker start mariadb`

Check that it started:

`sudo docker logs mariadb`

* For Incremental backups see [the OpenStack docs](https://docs.openstack.org/kolla-ansible/latest/admin/mariadb-backup-and-restore.html)
