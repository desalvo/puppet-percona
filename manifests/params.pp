class percona::params {

  case $::osfamily {

    'RedHat': {

        $percona_conf = '/etc/my.cnf'
        $galera_provider = '/usr/lib64/libgalera_smm.so'
        $percona_host_table = "mysql/host.frm"
        $percona_compat_packages = [
                                     'Percona-Server-shared-51',
                                   ]

        $percona_galera_package_56  = 'Percona-XtraDB-Cluster-galera-56'
        $percona_server_packages_56 = [
                                      'Percona-XtraDB-Cluster-server-56',
                                      'percona-xtrabackup'
                                       ]
        $percona_client_packages_56 = [ 'Percona-XtraDB-Cluster-client-56' ]

        $percona_galera_package_default  = 'Percona-XtraDB-Cluster-galera-2'
        $percona_server_packages_default = [
                                           'Percona-XtraDB-Cluster-server-55',
                                           'percona-xtrabackup'
                                           ]
        $percona_client_packages_default = [ 'Percona-XtraDB-Cluster-client-55' ]

        $percona_service = 'mysql'

        yumrepo { "Percona":
            descr    => "CentOS \$releasever - Percona",
            baseurl  => "http://repo.percona.com/centos/$operatingsystemmajrelease/os/\$basearch/",
            enabled  => 1,
            gpgkey   => "http://www.percona.com/downloads/RPM-GPG-KEY-percona",
            gpgcheck => 1
        }

        $percona_repo = Yumrepo['Percona']
    }

    'Debian': {

        $percona_conf = '/etc/mysql/my.cnf'
        $galera_provider = '/usr/lib/libgalera_smm.so'
        $percona_host_table = "mysql/host.frm"

        $percona_galera_package_56  = 'percona-xtradb-cluster-galera-3.x'
        $percona_server_packages_56 = [
                                      'percona-xtradb-cluster-server-5.6',
                                      'percona-xtrabackup'
                                      ]
        $percona_client_packages_56 = [ 'percona-xtradb-cluster-client-5.6' ]

        $percona_galera_package_default  = 'percona-xtradb-cluster-galera-2.x'
        $percona_server_packages_default = [
                                           'percona-xtradb-cluster-server-5.5',
                                           'percona-xtrabackup'
                                           ]
        $percona_client_packages_default = [ 'percona-xtradb-cluster-client-5.5' ]

        $percona_service = 'mysql'
        $percona_keyprefix = "1C4CBDCD"
        $percona_keynum = "CD2EFD2A"

        exec {"import Percona key":
            path    => ['/bin', '/usr/bin'],
            command => "apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ${percona_keyprefix}${percona_keynum}",
            unless  => "apt-key export ${percona_keynum} 2>/dev/null | gpg - 2>/dev/null > /dev/null"
        }

        file {'/etc/apt/sources.list.d/percona.list':
            content => template('percona/percona.list.erb'),
            require => Exec["import Percona key"],
            notify  => Exec["apt update percona"]
        }

        exec {'apt update percona':
            path        => ['/bin', '/usr/bin'],
            command     => 'apt-get update',
            require     => File['/etc/apt/sources.list.d/percona.list'],
            refreshonly => true
        }

        $percona_repo = Exec['apt update percona']

    }

    default:   {
    }
  }

}
