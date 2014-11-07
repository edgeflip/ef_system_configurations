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
          $queues='bulk_create,partial_save,delayed_save,upsert,update_edges,get_or_create,px3,px4,oauth_token,extend_token,celery'
          $concurrency='2'
      } 'background': {
          # Background jobs such as saving to the database
          $queues='bulk_create,partial_save,delayed_save,upsert,update_edges,get_or_create,oauth_token,extend_token,celery'
          $concurrency='8'
      } 'user_facing': {
          # Tasks that need to be completed for the user to get a response
          $queues='px3,px4,celery'
          $concurrency='2'
      } 'fbsync_dynamo_writes': {
          # Feed crawler
          $queues='user_feeds,bg_upsert,bg_update_edges,bg_bulk_create,bg_partial_save'
          $concurrency='2'
      } 'fbsync_feed': {
          # Feed crawler
          $queues='user_feeds'
          $concurrency='4'
      } 'fbsync_initial_crawl': {
          $queues='initial_crawl'
          $concurrency='4'
      } 'fbsync_low_pri_crawl': {
          $queues='back_fill_crawl,incremental_crawl'
          $concurrency='4'
      } 'fbsync_comment_crawler': {
          # crawl_comments_and_likes
          $queues='crawl_comments_and_likes,page_likes'
          $concurrency='4'
      } 'fbsync_db': {
          $queues='bg_upsert,bg_update_edges,bg_bulk_create'
          $concurrency='4'
      } 'fbsync_partial_save': {
          $queues='bg_partial_save'
          $concurrency='4'
      } 'fbsync_full': {
          # Good for staging to put all the fbsync on one server
          $queues='user_feeds,initial_crawl,back_fill_crawl,incremental_crawl,bg_upsert,bg_update_edges,bg_partial_save,crawl_comments_and_likes,page_likes'
          $concurrency='2'
      } 'full_stack': {
          # All the queues combined
          $queues='px3,px4,bulk_create,partial_save,delayed_save,get_or_create,upsert,update_edges,user_feeds,bg_px4,bg_upsert,bg_update_edges,bg_partial_save,crawl_comments_and_likes,initial_crawl,back_fill_crawl,incremental_crawl,oauth_token,extend_token,celery,page_likes'
          $concurrency='2'
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
        require => Package['edgeflip'],
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

