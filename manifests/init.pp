# == Class: percona
#
# Module for Percona XtraDB management.
#
# === Parameters
#
# [*mysql_version*]
#   The Percona mysql version to be used. Currently 5.5 or 5.6
#
# [*root_password*]
#   The root password of the database
#
# [*old_passwords*]
#   Set this to true to support the old mysql 3.x hashes for the passwords
#
# [*datadir*]
#   The mysql data directory, defaults to /var/lib/mysql
#
# [*port*]
#   The mysql server port, defaults to 3306
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
#   Set this to true to allow using sepafate files for the innodb tablespace
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
  $thread_cache = "2",
  $query_cache_size = "64M",
  $thread_concurrency = 2,
  $max_allowed_packet = "128M",
  $log_warnings = undef,
) inherits params {
    class { percona::server:
        mysql_version                  => $mysql_version,
        root_password                  => $root_password,
        old_passwords                  => $old_passwords,
        port                           => $port,
        datadir                        => $datadir,
        server_id                      => $server_id,
        skip_slave_start               => $skip_slave_start,
        ist_recv_addr                  => $ist_recv_addr,
        wsrep_max_ws_size              => $wsrep_max_ws_size,
        wsrep_cluster_address          => $wsrep_cluster_address,
        wsrep_provider                 => $wsrep_provider,
        wsrep_max_ws_rows              => $wsrep_max_ws_rows,
        wsrep_sst_receive_address      => $wsrep_sst_receive_address,
        wsrep_slave_threads            => $wsrep_slave_threads,
        wsrep_sst_method               => $wsrep_sst_method,
        wsrep_sst_auth                 => $wsrep_sst_auth,
        wsrep_cluster_name             => $wsrep_cluster_name,
        binlog_format                  => $binlog_format,
        default_storage_engine         => $default_storage_engine,
        innodb_autoinc_lock_mode       => $innodb_autoinc_lock_mode,
        innodb_locks_unsafe_for_binlog => $innodb_locks_unsafe_for_binlog,
        innodb_buffer_pool_size        => $innodb_buffer_pool_size,
        innodb_log_file_size           => $innodb_log_file_size,
        bulk_insert_buffer_size        => $bulk_insert_buffer_size,
        innodb_flush_log_at_trx_commit => $innodb_flush_log_at_trx_commit,
        innodb_file_per_table          => $innodb_file_per_table,
        innodb_file_format             => $innodb_file_format,
        innodb_file_format_max         => $innodb_file_format_max,
        sort_buffer_size               => $sort_buffer_size,
        read_buffer_size               => $read_buffer_size,
        read_rnd_buffer_size           => $read_rnd_buffer_size,
        key_buffer_size                => $key_buffer_size,
        myisam_sort_buffer_size        => $myisam_sort_buffer_size,
        thread_cache                   => $thread_cache,
        query_cache_size               => $query_cache_size,
        thread_concurrency             => $thread_concurrency,
        max_allowed_packet             => $max_allowed_packet,
        log_warnings                   => $log_warnings,
    }
}
