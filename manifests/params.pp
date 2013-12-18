class percona::params {

  case $::osfamily {
    'RedHat':  {
      $percona_compat_packages = [
                                   'Percona-Server-shared-compat',
                                 ]
      case $mysql_version {
        '5.6': {
          $percona_server_packages = [
                                       'Percona-XtraDB-Cluster-server-56',
                                       'Percona-XtraDB-Cluster-galera-56',
                                       'percona-xtrabackup'
                                     ]
          $percona_client_packages = [ 'Percona-XtraDB-Cluster-client-56' ]
        }
        default: {
          $percona_server_packages = [
                                       'Percona-XtraDB-Cluster-server-55',
                                       'Percona-XtraDB-Cluster-galera-2',
                                       'percona-xtrabackup'
                                     ]
          $percona_client_packages = [ 'Percona-XtraDB-Cluster-client-55' ]
        }
      }
      $percona_service = 'mysql'
    }
    default:   {
    }
  }

}
