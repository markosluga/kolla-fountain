# Backup mariadb and restore

## Prep the environment

** The madiadb backup user creation only works from Xena onwards **

***WARNING:*** If you are not using Xena, enabiling backups will fail with the following error:

`FAILED! => {"action": "mysql_user", "changed": false, "msg": "(1064, \"You have an error in your SQL syntax; check the manual that corresponds to your MariaDB server version for the right syntax to use near 'BINLOG MONITOR ON *.* TO 'backup'@'%'' at line 1\")"}`

1. Deploy Xena and enable backups via globals.yml:

`enable_mariabackup: "yes"`

2. you have deployed Xena allready and you can just reconfigure globals.yaml and run:

`kolla-ansible -i INVENTORY reconfigure -t mariadb`

3. If you are deploying a new deployment just redeploy with:

`kolla-ansible -i ~/multinode deploy`

4. Wait till deployment completes.

## Backup

1. To perform a full backup, run the following command:

`kolla-ansible -i INVENTORY mariadb_backup`

This will create a mariadb_backup volume and a /backup directory in which a dump of the mariadb database will be stored. It is recommended that this backup volume is regularly backed up to a storage location off of the control nodes. A simple script that runs the above command and then copies the volume to a safe location is a good idea to have.

## Restore

### Restoring a full backup

1.Ensure that the mariadb_backup volume is present on the control node where you are planning to perform the restore. 

2.Create a restore container with the volume attached:

`sudo docker run --rm -it --volumes-from mariadb --name dbrestore --volume mariadb_backup:/backup kolla/ubuntu-binary-mariadb-server:xena /bin/bash`

* replace `ubuntu-binary-mariadb-server:xena` with your version if it is newer than xena

3. Run the restore commands inside the restore container:

`cd /backup`

`rm -rf /backup/restore`

`mkdir -p /backup/restore/full`

`gunzip mysqlbackup-01-11-2021-1635773719.qp.xbc.xbs.gz`

`mbstream -x -C /backup/restore/full/ <  mysqlbackup-01-11-2021-1635773719.qp.xbc.xbs`

`mariabackup --prepare --target-dir /backup/restore/full`

`exit`

3. Stop the restore container:

`sudo docker stop mariadb`

4. Start up a new mariadb container:

`sudo docker run --rm -it --volumes-from mariadb --name dbrestore --volume mariadb_backup:/backup kolla/ubuntu-binary-mariadb-server:xena /bin/bash`

* replace `ubuntu-binary-mariadb-server:xena` with your version if it is newer than xena

5. Restore mariadb to the new container:

`rm -rf /var/lib/mysql/*`

`rm -rf /var/lib/mysql/\.[^\.]*`

`mariabackup --copy-back --target-dir /backup/restore/full`

`exit`

6. Now start mariadb:

`sudo docker start mariadb`

7. Check that it started:

`sudo docker logs mariadb`

* For Incremental backups see [the OpenStack docs](https://docs.openstack.org/kolla-ansible/latest/admin/mariadb-backup-and-restore.html)
