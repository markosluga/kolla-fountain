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

2. To check that the new volume has been created run the following command and see if you have a volume called **mariadb_backup**:

`sudo docker volume list`

3. To see what mountpoint you have run:

`sudo docker volume show mariadb_backup`

4. Look for the Mountpoint key-value pair that looks like this: `"Mountpoint": "/var/lib/docker/volumes/mariadb_backup/_data",`

List the backup volume files with the following command, replacing `/var/lib/docker/volumes/mariadb_backup/_data` to what the ooutput of your mountpoint is:

`sudo ls -l /var/lib/docker/volumes/mariadb_backup/_data`

5. The output should include the following file:

*-rw-r--r-- 1 42434 42434 1957783 Dec  1 21:06 mysqlbackup-01-12-2021-1638392789.qp.xbc.xbs.gz*

You are encouraged to back this file up off of the cluster control nodes as well.

* If you prefer to do incremental backups see [the OpenStack docs](https://docs.openstack.org/kolla-ansible/latest/admin/mariadb-backup-and-restore.html)


## Restore

### Restoring a full backup

6. Now we need to replicate this backup to the other controller nodes. 

Copu the backup file from the volume to the home. 

`sudo cp /var/lib/docker/volumes/mariadb_backup/_data/mysqlbackup-01-12-2021-1638392789.qp.xbc.xbs /home/kolla/mysqlbackup-01-12-2021-1638392789.qp.xbc.xbs.gz`

7. Change the ownership so we can shipt it to the other nodes:

`sudo chown $USER:$USER ~/mysqlbackup-01-12-2021-1638392789.qp.xbc.xbs.gz`  

8. Copy it over to each of the other controller nodes:

`scp ~/mysqlbackup-01-12-2021-1638392789.qp.xbc.xbs.gz kolla@kolla06:/home/kolla/mysqlbackup-01-12-2021-1638392789.qp.xbc.xbs.gz`

* Replace kolla06 with your host names

9. On youre other **controller nodes**, create a mariadb_backup docker volume and Copy the backup file into the volume.

`sudo docker volume create mariadb_backup`

`sudo cp ~/mysqlbackup-01-12-2021-1638392789.qp.xbc.xbs.gz /var/lib/docker/volumes/mariadb_backup/_data/mysqlbackup-01-12-2021-1638392789.qp.xbc.xbs.gz`

10. Change the owner to the docker user ID of the output in step 5. 

`sudo chown 42434:42434 /var/lib/docker/volumes/mariadb_backup/_data`

`sudo chown 42434:42434 /var/lib/docker/volumes/mariadb_backup/_data/mysqlbackup-01-12-2021-1638392789.qp.xbc.xbs.gz'

* Replace 42434 with the ID that matrches your docker mariadb user 

11.Ensure that the mariadb_backup volume is present on the control node where you are planning to perform the restore. 

12.Create a restore container with the volume attached:

`sudo docker run --rm -it --volumes-from mariadb --name dbrestore --volume mariadb_backup:/backup kolla/ubuntu-binary-mariadb-server:xena /bin/bash`

* replace `ubuntu-binary-mariadb-server:xena` with your version ***if it is newer than xena***

You should now see a command prompt like this - `()[mysql@1863273b794d /]$` - you are now in the newly created container.

13. Run the restore commands inside the restore container:

`cd /backup`

`rm -rf /backup/restore`

`mkdir -p /backup/restore/full`

* Replace 'mysqlbackup-01-12-2021-1638392789.qp.xbc.xbs.gz' with your file name in the following 2 commands:

`gunzip mysqlbackup-01-12-2021-1638392789.qp.xbc.xbs.gz`

`mbstream -x -C /backup/restore/full/ <  mysqlbackup-01-12-2021-1638392789.qp.xbc.xbs`

`mariabackup --prepare --target-dir /backup/restore/full`

`exit`

14. Stop the restore container:

`sudo docker stop mariadb`

15. Start up a new mariadb container:

`sudo docker run --rm -it --volumes-from mariadb --name dbrestore --volume mariadb_backup:/backup kolla/ubuntu-binary-mariadb-server:xena /bin/bash`

* replace `ubuntu-binary-mariadb-server:xena` with your version if it is newer than xena

16. Restore mariadb to the new container:

`rm -rf /var/lib/mysql/*`

`rm -rf /var/lib/mysql/\.[^\.]*`

`mariabackup --copy-back --target-dir /backup/restore/full`

`exit`

17. Now start mariadb:

`sudo docker start mariadb`

18. Check that it started:

`sudo docker ps | grep mariadb`

19. Verify that you have ran these steps on all nodes.

20. At this point the documentation says your cluster should be up and running. Mine never did so after I completed the steps above on all mariadb nodes I ran the mariadb_recovery to restore OpenStack functionality. If you run the recovery without overwriting the database backup to ALL nodes mariadb_recovery will recover the newest database state and not the backup that you are trying to restore. If this happens just go back to step 6 and re-run all the commands on ALL mariadb (controller) nodes.

`kolla-ansible -i ~/multinode mariadb_recovery`

Your cluster should be up and running now.

* To restore an incremental backups see [the OpenStack docs](https://docs.openstack.org/kolla-ansible/latest/admin/mariadb-backup-and-restore.html)

* Right now the procedure required to bring the cluster up after a restrore needs step 20 - this is not described in the OpenStack documentation. 

* [I have submitted a bug, and a workaround](https://bugs.launchpad.net/kolla-ansible/+bug/1952966)
