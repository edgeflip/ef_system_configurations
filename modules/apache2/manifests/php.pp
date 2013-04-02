# NOTE: libapache2-mod-fastcgi requires multiverse apt sources, make sure they
# are enabled in the cloud init


class apache2::php ( $minimal=true ) {
  include mysql::php

  #apache2-mpm-worker, then removing it and replacing with apache2-mpm-prefork in
  #PHP class

  if $minimal {
    $apache2_php_packages = [ 'libapache2-mod-fastcgi', 'php5-mcrypt', 'php-apc', 'php5-suhosin',
                              'php5-curl', 'php5-memcache', 'php5-memcached', 'php5-cli', 'php5-gd',
                              'php5-gmp', ]

  } else {
    $apache2_php_packages = [ 'php5', 'php5-cgi', 'php5-cli', 'php5-common',
    'php5-curl', 'php5-dev', 'php5-fpm', 'php5-gd', 'php5-mcrypt',
    'php5-memcached', 'php5-memcache', 'php5-suhosin', 'php-apc',
    'libapache2-mod-fastcgi', 'php5-imap' ]
  }

  #php5-fpm MUST run before any other php-related packages
  package { 'php5-fpm':
    ensure => present,
    before => Class['mysql::php'],
  }

  package { $apache2_php_packages:
    ensure  => present,
    require => Package['php5-fpm']
  }

  # the packages below shouldn't ever be installed, but need to ensure they
  # aren't.
  package { 'libapache2-mod-php5':
    ensure => purged,
  }

  # disabled to avoid bizarre caching problems, potentially related to php-apc
  # (apache will serve the wrong page)
  package { 'libapache2-mod-php5filter':
    ensure => purged,
    notify => Service['apache2'],
  }

  rsyslog::importconfig { 'suhosin':
    source => 'puppet:///modules/apache2/php/suhosin-rsyslog.conf',
  }

  # TODO: need to find a way to parameterize these timeouts, per node
  file { '/etc/php5/fpm/php.ini':
    ensure  => present,
    source  => 'puppet:///modules/apache2/php/php.ini',
    require => Package['php5-fpm'],
  }

  service { 'php5-fpm':
    name       => 'php5-fpm',
    ensure     => running,
    hasstatus  => false,
    status     => "/bin/pidof php5-fpm",
    hasrestart => false,
    restart    => "/usr/sbin/service php5-fpm reload",
    subscribe  => Package[$apache2_php_packages],
    require    => Package['apache2'],
    notify     => Service['apache2'],
  }

}
