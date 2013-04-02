class rsyslog {

  package { 'rsyslog':
    ensure => installed,
  }

  service { 'rsyslog':
    ensure  => running,
    require => Package['rsyslog'],
  }

}
