puppet-percona
======

Puppet module for managing Percona XtraDB.

#### Table of Contents
1. [Overview - What is the percona module?](#overview)

Overview
--------

This module is intended to be used to manage the Percona XtraDB system configuration.
[Percona XtraDB](http://www.percona.com/software/percona-xtradb) is an enhanced version of the InnoDB storage engine for MySQL® and MariaDB®.

Parameters
----------

The following parameters are supported:

* **mysql_version**: the Percona mysql version to be used. Currently 5.5 or 5.6 [default: 5.5]
* **root_password**: the root password of the database [default: unset]
* **old_passwords**: set this to true to support the old mysql 3.x hashes for the passwords [default: false]
* **datadir**: the mysql data directory [default: /var/lib/mysql]
* **server_id**: the server id [default: 1]
* **skip_slave_start**: set this to true to skip the slave startup on boot [default: true]
* **ist_recv_addr**: the IST receiver address for WSREP [default: ipaddress]
* **wsrep_max_ws_size**: the WSREP max working set size [default: 2G]
* **wsrep_cluster_address**: the WSREP cluster address list, like gcomm://<ip1>:4010,<ip2>:4010 [default: gcomm://]
* **wsrep_provider**: the WSREP provider [default: libgalera_smm.so]
* **wsrep_max_ws_rows**: the WSREP max working set rows [default: 1024000]
* **wsrep_sst_receive_address**: the SST receiver address [default: ipaddress:4020]
* **wsrep_slave_threads**: number of WSREP slave threads [default: 2]
* **wsrep_sst_method**: the WSREP SST method, like rsync or xtrabackup [default: rsync]
* **wsrep_sst_auth**: the auth string for SST, if needed [default: undef]
* **wsrep_cluster_name**: the WSREP cluster name [default: default]
* **binlog_format**: the binlog format [default: ROW]
* **default_storage_engine**: the default storage engine [default: InnoDB]
* **innodb_autoinc_lock_mode**: the innodb lock mode [default: 2]
* **innodb_locks_unsafe_for_binlog**: set this to true if you want to use unsafe locks for the binlogs [default: 1]
* **innodb_buffer_pool_size**: the innodb buffer pool size [default: 128M]
* **innodb_log_file_size**: the innodb log file size [default: 256M]
* **bulk_insert_buffer_size**: the size of the insert buffer [default: 128M]
* **innodb_flush_log_at_trx_commit**: set this to allow flushing of logs at transaction commit [default: 2]
* **innodb_file_per_table**: set this to true to allow using sepafate files for the innodb tablespace [default: true]
* **innodb_file_format**: the file format for innodb [default: Barracuda]
* **innodb_file_format_max**: the higher level of file formats for innodb [default: Barracuda]
* **sort_buffer_size**: the size of the sort buffer [default: 64M]
* **read_buffer_size**: the size of the read buffer [default: 64M]
* **read_rnd_buffer_size**: the size of the rnd buffer [default: 64M]
* **key_buffer_size**: size of keys [default: 64M]
* **myisam_sort_buffer_size**: the myisam sort buffer size [default: 64M]
* **thread_cache**: the number of thread caches [default: 2]
* **query_cache_size**: the size of the query cache [default: 64M]
* **thread_concurrency**: number of allowed concurrent threads [default: 2]

Usage
-----

### Example

This is a simple example to configure a percona server.

**Using the percona XtraDB module**

```percona
class { 'percona':
    root_password => 'dummy_password',
    wsrep_cluster_address => 'gcomm://192.168.0.1:4010,192.168.0.2:4010',
    wsrep_cluster_name => 'mycluster'
}
```

Please note that in case you already have other DB machines in the cluster you will need to use the same value of innodb_log_file_size for all the components of the cluster.

Contributors
------------

* https://github.com/desalvo/puppet-percona/graphs/contributors

Release Notes
-------------

**0.1.6**

* Replaced consensus_timeout with install_timeout
* Updated compat package

**0.1.5**

* Fixed mysql db initialization when using a custom datadir location

**0.1.10**

* Fixed behaviour with multiple versions and bad key server on Debian/Ubuntu
* Refactoring of the module internals

**0.1.4**

* Better handling of the datadir parameter

**0.1.3**

* Fixed bug on percona startup procedure

**0.1.2**

* Improved documentation

**0.1.1**

* Added support for Ubuntu/Debian.
* Better handling of the initial setup.

**0.1.0**

* Initial version.
