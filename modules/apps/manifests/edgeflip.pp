class apps::baseflip {

  package { 'edgeflip':
    ensure  => latest,
    require => [ Package['python-pip'],
                 Package['python-dev'],
                 Package['gcc'],
                 Package['python-mysqldb'],
                 Package['build-essential'],
                 Package['libmysqlclient-dev'],
                 Package['virtualenvwrapper'],
                 Package['graphviz'], ],
    notify  => [ Exec['fix_perms'],
                 Exec['move_configs'], ],
  }

  package { 'build-essential':
    ensure  => installed,
  }

  package { 'graphviz':
    ensure  => installed,
  }

  package { 'libmysqlclient-dev':
    ensure  => installed,
  }

  package { 'virtualenvwrapper':
    ensure  => installed,
  }

  package { 'python-pip':
    ensure  => installed,
  }

  package { 'gcc':
    ensure  => installed,
  }

  package { 'python-dev':
    ensure  => installed,
  }

  package {'python-mysqldb':
  ensure    => installed,
  }

  file { '/var/www/edgeflip/conf.d':
    ensure  => directory,
    require => Package['edgeflip'],
    notify  => Exec['move_configs'],
  }

  file { '/opt/fix-perms.sh':
    ensure  => file,
    mode    => "0755",
    source  => 'puppet:///modules/apps/edgeflip/fix-perms.sh',
  }

  file { '/var/www/edgeflip/newrelic.ini':
    ensure  => file,
    source  => '/root/creds/app/newrelic.ini',
    owner   => 'www-data',
    group   => 'www-data',
    notify  => Service['apache2'],
    require => Package['edgeflip'],
  }

  exec { 'move_configs':
    command     => '/usr/bin/sudo /bin/cp -r /root/creds/app/* /var/www/edgeflip/conf.d/',
    refreshonly => true,
    require     => [ Package['edgeflip'], File['/var/www/edgeflip/conf.d'], ],
    notify      => [ Service['apache2'], Exec['fix_perms'], ]
  }

  exec { 'fix_perms':
    command     => '/opt/fix-perms.sh',
    refreshonly => true,
    require     => [ Package['edgeflip'],
                     File['/opt/fix-perms.sh'] ],
    notify      => Service['apache2'],
  }

  rsyslog::importconfig { 'edgeflip':
    source => 'puppet:///modules/apps/edgeflip/rsyslog.conf',
  }

}

class apps::webflip ( $env='production' ) {

  include apps::baseflip
  case $env {
    'production': {
      $edgeflip_env='production'
      $edgeflip_hostname='www.edgeflip.com'
    } 'staging': {
      $edgeflip_env='staging'
      $edgeflip_hostname='edgeflip.efstaging.com'
    }
  }

  apache2::templatevhost { "$edgeflip_hostname":
    content => template('apps/edgeflip/vhost.erb'),
    require => Package['edgeflip'],
  }
}


class apps::celeryflip ( $env='production', $celerytype='standard' ) {

  include apps::baseflip
  case $env {
    'production': {
      $edgeflip_env='production'
      $edgeflip_hostname='www.edgeflip.com'
    } 'staging': {
      $edgeflip_env='staging'
      $edgeflip_hostname='edgeflip.efstaging.com'
    }
  }

  apache2::templatevhost { "$edgeflip_hostname":
    content => template('apps/edgeflip/vhost.erb'),
    require => Package['edgeflip'],
  }

    # Celery related items
    group { 'celery':
      ensure  => present,
      system  => true,
    }

    user { 'celery':
      ensure   => present,
      system   => true,
      gid      => 'celery',
      require  => Group['celery'],
    }

    file { '/var/run/celery':
      ensure  => directory,
      owner   => 'celery',
      group   => 'celery',
      require => User['celery'],
    }

    file { '/var/log/celery':
      ensure  => directory,
      owner   => 'celery',
      group   => 'celery',
      require => User['celery'],
    }

    if $celerytype == 'standard' {
        file { '/etc/default/celeryd':
          ensure  => file,
          source  => 'puppet:///modules/apps/edgeflip/main_celeryd.conf',
          require => Package['edgeflip'],
          notify  => Service['celeryd'],
        }
    } else {
        file { '/etc/default/celeryd':
          ensure  => file,
          source  => 'puppet:///modules/apps/edgeflip/fb_sync_celeryd.conf',
          require => Package['edgeflip'],
          notify  => Service['celeryd'],
        }
    }

    file { "/etc/init.d/celeryd":
      ensure  => link,
      target  => "/var/www/edgeflip/edgeflip/etc/celeryd",
      require => Package['edgeflip'],
      notify  => Service['celeryd'],
    }

    service { 'celeryd':
      ensure     => running,
      hasstatus  => true,
      hasrestart => true,
      status     => "/etc/init.d/celeryd status",
      subscribe  => Service['apache2'],
    }
}
