class percona::params {

  case $::osfamily {
    'RedHat': {
      $percona_conf = '/etc/my.cnf'
      $galera_provider = '/usr/lib64/libgalera_smm.so'
      $percona_host_table = "mysql/user.frm"
      $percona_service = 'mysql'
      yumrepo { "Percona":
          descr    => "CentOS \$releasever - Percona",
          baseurl  => "http://repo.percona.com/centos/$operatingsystemmajrelease/os/\$basearch/",
          enabled  => 1,
          gpgkey   => "https://repo.percona.com/yum/PERCONA-PACKAGING-KEY",
          gpgcheck => 1
      }
      yumrepo { "Percona-noarch":
          descr    => "CentOS \$releasever noarch - Percona",
          baseurl  => "http://repo.percona.com/centos/$operatingsystemmajrelease/os/noarch/",
          enabled  => 1,
          gpgkey   => "https://repo.percona.com/yum/PERCONA-PACKAGING-KEY",
          gpgcheck => 1
      }
      $percona_repo = [Yumrepo['Percona'],Yumrepo['Percona-noarch']]
    }
    'Debian': {
      $percona_conf = '/etc/mysql/my.cnf'
      $galera_provider = '/usr/lib/libgalera_smm.so'
      $percona_host_table = "mysql/user.frm"
      $percona_service = 'mysql'
      $percona_keyprefix = "1C4CBDCD"
      $percona_keynum = "CD2EFD2A"
      exec {"import Percona key":
          path    => ['/bin', '/usr/bin'],
          command => "apt-key adv --keyserver keys.gnupg.net --recv-keys ${percona_keyprefix}${percona_keynum}",
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
