puppet-percona
======

Puppet module for managing Percona XtraDB.

#### Table of Contents
1. [Overview - What is the percona module?](#overview)

Overview
--------

This module is intended to be used to manage the Percona XtraDB system configuration.
[Percona XtraDB](http://www.percona.com/software/percona-xtradb) is an enhanced version of the InnoDB storage engine for MySQL® and MariaDB®.

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

**0.1.1**

* Added support for Ubuntu/Debian.
* Better handling of the initial setup.

**0.1.0**

* Initial version.
