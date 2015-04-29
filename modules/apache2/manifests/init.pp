class apache2 ( $mpm='worker' ) {

  package { "apache2-mpm-$mpm":
    ensure => present,
    alias  => 'apache2',
  }

  service { 'apache2':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    # subscribe  => [Package['apache2'], File['/var/www/edgeflip/newrelic.ini'], Exec['move_configs'], Exec['fix_perms']],
    subscribe  => Package['apache2'],
    status     => "/etc/init.d/apache2 status",
  }

  file { '/etc/apache2/sites-enabled/':
    ensure  => directory,
    recurse => true,
    purge   => true,
    require => Package['apache2'],
    notify  => Service['apache2'],
  }

  file { '/etc/apache2/sites-available/':
    ensure  => directory,
    recurse => true,
    purge   => true,
    require => Package['apache2'],
    notify  => Service['apache2'],
  }

  #disable default apache icons
  file { '/etc/apache2/mods-enabled/alias.conf':
    ensure  => absent,
    require => Package['apache2'],
    notify  => Service['apache2'],
  }

  #required to strip headers in base security file
  apache2::mods::enable { 'headers': }

  file { '/etc/apache2/conf.d/security':
    ensure  => file,
    source  => 'puppet:///modules/apache2/security',
    require => Package['apache2'],
    notify  => Service['apache2'],
  }

  file { '/etc/apache2/conf.d/log_formats':
    ensure  => file,
    source  => 'puppet:///modules/apache2/log_formats',
    require => Package['apache2'],
    notify  => Service['apache2'],
  }

  file { '/etc/apache2/conf.d/other-vhosts-access-log':
    ensure  => file,
    source  => 'puppet:///modules/apache2/other-vhosts-access-log',
    require => Package['apache2'],
    notify  => Service['apache2'],
  }

  rsyslog::importconfig { 'apache':
    source  => 'puppet:///modules/apache2/rsyslog.conf',
  }

  file { '/etc/apache2/conf.d/syslog_errors':
    ensure  => file,
    source  => 'puppet:///modules/apache2/syslog_errors',
    require => Package['apache2'],
    notify  => Service['apache2'],
  }

}
