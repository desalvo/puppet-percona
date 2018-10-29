class percona::zabbix::agent (
  $mysql_pass,
  $mysql_user           = 'root',
  $zabbix_agent_include = '/etc/zabbix/zabbix_agentd.d',
  $zabbix_agent_service = 'zabbix-agent',
  $zabbix_home          = '/var/lib/zabbix',
) inherits ::percona::params {
  if ($::osfamily == 'RedHat') {
    if (!defined(Package['php']))       { package {'php': ensure => latest} }
    if (!defined(Package['php-mysql'])) { package {'php-mysql': ensure => latest} }

    package {'percona-zabbix-templates':
      ensure  => installed,
      require => $::percona::params::percona_repo,
    }
    file {
      "${zabbix_agent_include}/userparameter_percona_mysql.conf":
        ensure  => 'present',
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => '/var/lib/zabbix/percona/templates/userparameter_percona_mysql.conf',
        require => Package['percona-zabbix-templates'],
        notify  => Service[$zabbix_agent_service];
      '/var/lib/zabbix/percona/scripts/ss_get_mysql_stats.php.cnf':
        ensure  => 'present',
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template("${module_name}/zabbix/ss_get_mysql_stats.php.cnf.erb"),
        require => File["${zabbix_agent_include}/userparameter_percona_mysql.conf"];
      "$zabbix_home/.my.cnf":
        ensure  => present,
        owner   => 'zabbix',
        group   => 'zabbix',
        mode    => '0600',
        content => template("${module_name}/user/my.cnf.erb");
    }
  }
}
