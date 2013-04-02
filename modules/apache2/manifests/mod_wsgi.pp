class apache2::mod_wsgi {

  package { 'libapache2-mod-wsgi':
    ensure  => latest,
    require => Package['apache2'],
    notify  => Service['apache2'],
   }

}
