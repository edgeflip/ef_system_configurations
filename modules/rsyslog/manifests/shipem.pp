class rsyslog::shipem ($syslog_host='loggins.efprod.com', $syslog_port='514',
                       $transport='tcp') {

  file { "/etc/rsyslog.d/02-ship-remote.conf":
    ensure  => present,
    content => template('rsyslog/ship-remote.conf.erb'),
    require => Package['rsyslog'],
    notify  => Service['rsyslog']
  }

}
