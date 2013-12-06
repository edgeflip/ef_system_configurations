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

