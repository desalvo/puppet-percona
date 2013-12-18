# == Class: percona
#
# Module for Percona XtraDB management.
#
# === Parameters
#
# [*gcomm*]
#   The galera wsrep_cluster_address parameters
#
# [*mysql_version*]
#   The Percona mysql version to be used. Currently 5.5 or 5.6
#
# [*root_password*]
#   The root password of the database
#
# [*old_passwords*]
#   Set this to tru to support the old mysql 3.x hashes for the passwords
#
# [*datadir*]
#   The mysql data directory, defaults to /var/lib/mysql
#
# [*server_id*]
#   The server id, defaults to 1
#
# [*skip_slave_start*]
#   Set this to true to skip the slave startup on boot
#
# [*ist_recv_addr*]
#   The IST receiver address for WSREP
#
# [*wsrep_max_ws_size*]
#   The WSREP max working set size
#
# [*wsrep_cluster_address*]
#   The WSREP cluster address list, like gcomm://<ip1>:4010,<ip2>:4010
#
# [*wsrep_provider*]
#   The WSREP provider
#
# [*wsrep_max_ws_rows*]
#   The WSREP max working set rows
#
# [*wsrep_sst_receive_address*]
#   The SST receiver address
#
# [*wsrep_slave_threads*]
#   Number of WSREP slave threads
#
# [*wsrep_sst_method*]
#   The WSREP SST method, like rsync or xtrabackup
#
# [*wsrep_sst_auth*]
#   The auth string for SST, if needed
#
# [*wsrep_cluster_name*]
#   The WSREP cluster name
#
# [*binlog_format*]
#   The binlog format
#
# [*default_storage_engine*]
#   The default storage engine
#
# [*innodb_autoinc_lock_mode*]
#   The innodb lock mode
#
# [*innodb_locks_unsafe_for_binlog*]
#   Set this to true if you want to use unsafe locks for the binlogs
#
# [*innodb_buffer_pool_size*]
#   The innodb buffer pool size
#
# [*innodb_log_file_size*]
#   The innodb log file size
#
# [*bulk_insert_buffer_size*]
#   The size of the insert buffer
#
# [*innodb_flush_log_at_trx_commit*]
#   Set this to allow flushing of logs at transaction commit
#
# [*innodb_file_per_table*]
#   Set this to tru to allow using sepafate files for the innodb tablespace
#
# [*innodb_file_format*]
#   The file format for innodb
#
# [*innodb_file_format_max*]
#   The higher level of file formats for innodb
#
# [*sort_buffer_size*]
#   The size of the sort buffer
#
# [*read_buffer_size*]
#   The size of the read buffer
#
# [*read_rnd_buffer_size*]
#   The size of the rnd buffer
#
# [*key_buffer_size*]
#   Size for keys
#
# [*myisam_sort_buffer_size*]
#   The myisam sort buffer size
#
# [*thread_cache*]
#   The number of thread caches
#
# [*query_cache_size*]
#   The size of the query cache
#
# [*thread_concurrency*]
#   Number of allowed concurrent threads
#
#
# === Examples
#
#  class { percona:
#    wsrep_cluster_address => 'gcomm://192.168.0.1:4010,192.168.0.2:4010'
#  }
#
# === Authors
#
# Alessandro De Salvo <Alessandro.DeSalvo@roma1.infn.it>
#
# === Copyright
#
# Copyright 2013 Alessandro De Salvo
#
class percona (
  $mysql_version = "5.5",
  $root_password = undef,
  $old_passwords = false,
  $datadir = "/var/lib/mysql",
  $server_id = 1,
  $skip_slave_start = true,
  $ist_recv_addr = $ipaddress,
  $wsrep_max_ws_size = "2G",
  $wsrep_cluster_address = "gcomm://",
  $wsrep_provider = "/usr/lib64/libgalera_smm.so",
  $wsrep_max_ws_rows = 1024000,
  $wsrep_sst_receive_address = "${ipaddress}:4020",
  $wsrep_slave_threads = 2,
  $wsrep_sst_method = "rsync",
  $wsrep_sst_auth = undef,
  $wsrep_cluster_name = "default",
  $binlog_format = "ROW",
  $default_storage_engine = "InnoDB",
  $innodb_autoinc_lock_mode = 2,
  $innodb_locks_unsafe_for_binlog = 1,
  $innodb_buffer_pool_size = "128M",
  $innodb_log_file_size = "256M",
  $bulk_insert_buffer_size = "128M",
  $innodb_flush_log_at_trx_commit = 2,
  $innodb_file_per_table = true,
  $innodb_file_format = "Barracuda",
  $innodb_file_format_max = "Barracuda",
  $sort_buffer_size = "64M",
  $read_buffer_size = "64M",
  $read_rnd_buffer_size = "64M",
  $key_buffer_size = "64M",
  $myisam_sort_buffer_size = "64M",
  $thread_cache = "2",
  $query_cache_size = "64M",
  $thread_concurrency = 2,
  $max_allowed_packet = "128M",
) inherits params {
    yumrepo { "Percona":
        descr    => "CentOS \$releasever - Percona",
        baseurl  => "http://repo.percona.com/centos/$operatingsystemmajrelease/os/\$basearch/",
        enabled  => 1,
        gpgkey   => "http://www.percona.com/downloads/RPM-GPG-KEY-percona",
        gpgcheck => 1
    }
    package { $percona::params::percona_compat_packages: }
    package { $percona::params::percona_server_packages: require => Package[$percona::params::percona_compat_packages] }
    package { $percona::params::percona_client_packages: require => Package[$percona::params::percona_server_packages] }
    $wsrep_provider_options = "gcache.size=${wsrep_max_ws_size}; gmcast.listen_addr=tcp://0.0.0.0:4010; ist.recv_addr=${ist_recv_addr}; evs.keepalive_period = PT3S; evs.inactive_check_period = PT10S; evs.suspect_timeout = PT30S; evs.inactive_timeout = PT1M; evs.consensus_timeout = PT1M;"

    file {'/etc/my.cnf':
        content => template('percona/my.cnf.erb'),
        notify => Service[$percona::params::percona_service],
    }

    service { $percona::params::percona_service:
        ensure => running,
        enable => true,
        require => Package[$percona::params::percona_server_packages],
    }

    if ($root_password) {
        exec {"set-percona-root-password":
            command => "mysqladmin -u root password \"$root_password\"",
            path    => ["/usr/bin"],
            onlyif  => "mysqladmin -u root status 2>&1 > /dev/null",
            require => Service [$percona::params::percona_service]
        }
    }
}
