class apache2::auth {

  file { '/var/www/passwords':
    ensure  => directory,
    owner   => root,
    group   => www-data,
    mode    => 0750,
    require => Class['apache2'],
  }

}
