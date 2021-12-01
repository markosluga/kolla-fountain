# Backup mariadb and restore

## Prep the environment

** The madiadb backup user creation only works from Xena onwards **

If you are not using Xena, enabiling backups will fail with the following error:

`FAILED! => {"action": "mysql_user", "changed": false, "msg": "(1064, \"You have an error in your SQL syntax; check the manual that corresponds to your MariaDB server version for the right syntax to use near 'BINLOG MONITOR ON *.* TO 'backup'@'%'' at line 1\")"}`

### Deploy Xena and enable backups via globals.yml:

`enable_mariabackup: "yes"`

If you have deployed Xena allready and you can just reconfigure globals.yaml and run:

`kolla-ansible -i INVENTORY reconfigure -t mariadb`

If you are deploying a new deployment just redeploy with:

`kolla-ansible -i ~/multinode deploy`

Wait till deployment completes.

## Backup

To perform a full backup, run the following command:

`kolla-ansible -i INVENTORY mariadb_backup`

This will create a mariadb_backup 

## Restore

### Restoring a full backup

Create a restore container:

`sudo docker run --rm -it --volumes-from mariadb --name dbrestore --volume mariadb_backup:/backup kolla/ubuntu-binary-mariadb-server:wallaby /bin/bash`

Run the restore commands in the restore container:

`cd /backup`

`rm -rf /backup/restore`

`mkdir -p /backup/restore/full`

`gunzip mysqlbackup-01-11-2021-1635773719.qp.xbc.xbs.gz`

`mbstream -x -C /backup/restore/full/ <  mysqlbackup-01-11-2021-1635773719.qp.xbc.xbs`

`mariabackup --prepare --target-dir /backup/restore/full`

exit
`
Stop the restore container:

`sudo docker stop mariadb`

Start up a new mariadb container:

`sudo docker run --rm -it --volumes-from mariadb --name dbrestore --volume mariadb_backup:/backup kolla/ubuntu-binary-mariadb-server:wallaby /bin/bash`

Restore mariadb to the new container:

`rm -rf /var/lib/mysql/*`

`rm -rf /var/lib/mysql/\.[^\.]*`

`mariabackup --copy-back --target-dir /backup/restore/full`

exit
`
Now start mariadb:

`sudo docker start mariadb`

Check that it started:

`sudo docker logs mariadb`

* For Incremental backups see [the OpenStack docs](https://docs.openstack.org/kolla-ansible/latest/admin/mariadb-backup-and-restore.html)
