# == Class: percona
#
# Module for Percona XtraDB management.
#
# === Parameters
#
# [*gcomm*]
#   The galera wsrep_cluster_address parameters
#
# === Examples
#
#  class { percona:
#    wsrep_cluster_address => [ 'pool.ntp.org', 'ntp.local.company.com' ],
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
