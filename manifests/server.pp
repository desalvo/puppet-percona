class percona::server (
  $mysql_version = "5.5",
  $root_password = undef,
  $old_passwords = false,
  $datadir = "/var/lib/mysql",
  $bind_address = undef,
  $port = "3306",
  $server_id = 1,
  $skip_slave_start = true,
  $ist_recv_addr = $ipaddress,
  $wsrep_max_ws_size = "2G",
  $wsrep_cluster_address = "gcomm://",
  $wsrep_provider = $percona::params::galera_provider,
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
  $max_connections = "151",
  $thread_cache = "2",
  $thread_stack = "256K",
  $tmpdir = "/tmp",
  $query_cache_limit = "1M",
  $query_cache_size = "64M",
  $table_open_cache = 400,
  $skip_external_locking = true,
  $ssl = false,
  $ssl_ca = undef,
  $ssl_cert = undef,
  $ssl_key = undef,
  $max_allowed_packet = "128M",
  $log_warnings = undef,
) inherits params {

  case $::osfamily {
    'RedHat': {
      if ($operatingsystemmajrelease * 1 < 7) {
        $percona_compat_packages = [
                                     'Percona-Server-shared-51',
                                   ]
      } else {
        $percona_compat_packages = []
      }
      case $mysql_version {
        '5.6': {
          $percona_galera_package  = 'Percona-XtraDB-Cluster-galera-3'
          $percona_server_packages = [
                                       'Percona-XtraDB-Cluster-server-56',
                                       'percona-xtrabackup'
                                     ]
          $percona_client_packages = [ 'Percona-XtraDB-Cluster-client-56' ]
        }
        default: {
          $percona_galera_package  = 'Percona-XtraDB-Cluster-galera-2'
          $percona_server_packages = [
                                       'Percona-XtraDB-Cluster-server-55',
                                       'percona-xtrabackup'
                                     ]
          $percona_client_packages = [ 'Percona-XtraDB-Cluster-client-55' ]
        }
      }
    }
    'Debian': {
      case $mysql_version {
        '5.6': {
          $percona_galera_package  = 'percona-xtradb-cluster-galera-3.x'
          $percona_server_packages = [
                                       'percona-xtradb-cluster-server-5.6',
                                       'percona-xtrabackup'
                                     ]
          $percona_client_packages = [ 'percona-xtradb-cluster-client-5.6' ]
        }
        default: {
          $percona_galera_package  = 'percona-xtradb-cluster-galera-2.x'
          $percona_server_packages = [
                                       'percona-xtradb-cluster-server-5.5',
                                       'percona-xtrabackup'
                                     ]
          $percona_client_packages = [ 'percona-xtradb-cluster-client-5.5' ]
        }
      }
    }
    default:   {
    }
  }

  if ($percona_compat_packages) {
      package { $percona_compat_packages: require => $percona::params::percona_repo }
      $percona_server_req = Package[$percona_compat_packages]
  } else {
      $percona_server_req = $percona::params::percona_repo
  }
  package { $percona_galera_package:  require => $percona_server_req }
  package { $percona_server_packages: require => Package[$percona_galera_package] }
  package { $percona_client_packages: require => Package[$percona_server_packages] }

  exec { "init percona db":
      command => "mysql_install_db",
      path    => [ '/bin', '/usr/bin' ],
      unless  => "test -f ${datadir}/${percona::params::percona_host_table}",
      require => [File[$percona::params::percona_conf],File[$datadir],Package[$percona_server_packages]],
      timeout => 0
  }

  $wsrep_provider_options = "gcache.size=${wsrep_max_ws_size}; gmcast.listen_addr=tcp://0.0.0.0:4010; ist.recv_addr=${ist_recv_addr}; evs.keepalive_period = PT3S; evs.inactive_check_period = PT10S; evs.suspect_timeout = PT30S; evs.inactive_timeout = PT1M; evs.install_timeout = PT1M;"

  file {$percona::params::percona_conf:
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('percona/my.cnf.erb'),
      require => Package[$percona_server_packages],
      notify  => Service[$percona::params::percona_service]
  }

  file {$datadir:
      ensure => directory,
      owner  => 'mysql',
      group  => 'mysql',
      require => Package[$percona_server_packages],
      notify  => Service[$percona::params::percona_service]
  }

  service { $percona::params::percona_service:
      ensure => running,
      enable => true,
      hasrestart => true,
      require => [File[$percona::params::percona_conf],Package[$percona_client_packages],Exec["init percona db"],File[$datadir]],
  }

  if ($root_password) {
      exec {"set-percona-root-password":
          command => "mysqladmin -u root password \"$root_password\"",
          path    => ["/usr/bin"],
          onlyif  => "mysqladmin -u root status 2>&1 > /dev/null",
          require => Service[$percona::params::percona_service]
      }
      file { '/root/.my.cnf':
          ensure => present,
          owner  => 'root',
          group  => 'root',
          mode   => '0600',
          content => template("${module_name}/root/my.cnf.erb"),
      }
  }

}
