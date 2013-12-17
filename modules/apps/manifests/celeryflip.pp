class apps::celeryflip ( $env='production', $celerytype='mixed' ) {

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

  case $celerytype {
      'mixed': {
          # Mixes background and front facing queues, mainly for staging
          # Later may fold fbsync processes into here as well
          $queues='bulk_create,partial_save,delayed_save,upsert,update_edges,get_or_create,px3,px3_filter,px4,celery'
      } 'background': {
          # Background jobs such as saving to the database
          $queues='bulk_create,partial_save,delayed_save,upsert,update_edges,get_or_create,celery'
      } 'user_facing': {
          # Tasks that need to be completed for the user to get a response
          $queues='px3,px3_filter,px4,celery'
      } 'fbsync': {
          # Feed crawler
          $queues='bg_px4,user_feeds,process_sync,celery'
      } 'full_stack': {
          # Feed crawler + mixed
          $queues='bg_px4,user_feeds,process_sync,bulk_create,partial_save,delayed_save,upsert,update_edges,get_or_create,px3,px3_filter,px4,celery'
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

    file { '/etc/default/celeryd' :
        ensure   => file,
        content  => template('apps/edgeflip/celeryd_template.erb'),
        required => Package['edgeflip'],
        notify   => Service['celeryd'],
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

