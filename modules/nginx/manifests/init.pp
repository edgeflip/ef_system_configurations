class nginx {

  package { 'nginx':
    ensure => latest,
  }

  service { 'nginx':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    subscribe  => Package['nginx'],
  }

  file { '/etc/nginx/sites-available/default':
    ensure  => absent,
    require => Package['nginx'],
    notify  => Service['nginx'],
  }

}
