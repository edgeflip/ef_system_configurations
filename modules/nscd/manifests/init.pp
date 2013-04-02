class nscd ( $ensure_job = 'running' ) {

  package { 'nscd':
    ensure  => present,
    require => File['/etc/nscd.conf'],
  }

  file { '/etc/nscd.conf':
    ensure  => file,
    content => template('nscd/nscd.conf.erb'),
    notify  => Service['nscd'],
  }

  service { 'nscd':
    ensure  => $ensure_job,
    require => [ Package['nscd'],
                 File['/etc/nscd.conf'], ],
    }
}
