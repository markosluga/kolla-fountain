# Backup mariadb and restore

## Prep the environment

** The madiadb backup user creation only works from ***Xena*** onwards **

***WARNING:*** *If you are not using Xena, enabiling backups will fail with the following error:*

`FAILED! => {"action": "mysql_user", "changed": false, "msg": "(1064, \"You have an error in your SQL syntax; check the manual that corresponds to your MariaDB server version for the right syntax to use near 'BINLOG MONITOR ON *.* TO 'backup'@'%'' at line 1\")"}`

1. Deploy Xena and enable backups via globals.yml by ensuring the following two values are configured:

`openstack_release: "xena"`

`enable_mariabackup: "yes"`

2. If you have only changed `enable_mariabackup: "yes"` and are working with an already deployed OpenStack on Xena then you can just reconfigure globals.yaml and run:

`kolla-ansible -i ~/multinode reconfigure -t mariadb`

3. If you are ***upgrading to Xena*** or deploying a new deployment redeploy with:

`kolla-ansible -i ~/multinode deploy`

4. Wait untill the deployment completes.

## Backup

1. To perform a full backup, run the following command:

`kolla-ansible -i ~/multinode mariadb_backup`

This will create a mariadb_backup volume and a /backup directory in which a dump of the mariadb database will be stored. It is recommended that this backup volume is regularly backed up to a storage location off of the control nodes. A simple script that runs the above command and then copies the volume to a safe location is a good idea to have.

To check that the new volume has been created run the following command and see if you have a volume called **mariadb_backup**:

`sudo docker volume list`

To see what mountpoint you have run:

`sudo docker volume show mariadb_backup`

Look for the Mountpoint key-value pair that looks like this: `"Mountpoint": "/var/lib/docker/volumes/mariadb_backup/_data",`

List the backup volume files with the following command, replacing `/var/lib/docker/volumes/mariadb_backup/_data` to what the ooutput of your mountpoint is:

`sudo ls -l /var/lib/docker/volumes/mariadb_backup/_data`

The output should include the following file:

-rw-r--r-- 1 42434 42434 1957783 Dec  1 21:06 mysqlbackup-01-12-2021-1638392789.qp.xbc.xbs.gz

You are encouraged to back this file up off of the cluster control node.

* If you prefer to do incremental backups see [the OpenStack docs](https://docs.openstack.org/kolla-ansible/latest/admin/mariadb-backup-and-restore.html)

## Restore

### Restoring a full backup

1.Ensure that the mariadb_backup volume is present on the control node where you are planning to perform the restore. 

2.Create a restore container with the volume attached:

`sudo docker run --rm -it --volumes-from mariadb --name dbrestore --volume mariadb_backup:/backup kolla/ubuntu-binary-mariadb-server:xena /bin/bash`

* replace `ubuntu-binary-mariadb-server:xena` with your version ***if it is newer than xena***

3. Run the restore commands inside the restore container:

`cd /backup`

`rm -rf /backup/restore`

`mkdir -p /backup/restore/full`

* Replace 'mysqlbackup-01-12-2021-1638392789.qp.xbc.xbs.gz' with your file name in the following 2 commands:

`gunzip mysqlbackup-01-12-2021-1638392789.qp.xbc.xbs.gz`

`mbstream -x -C /backup/restore/full/ <  mysqlbackup-01-12-2021-1638392789.qp.xbc.xbs`

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

* To restore an incremental backups see [the OpenStack docs](https://docs.openstack.org/kolla-ansible/latest/admin/mariadb-backup-and-restore.html)
