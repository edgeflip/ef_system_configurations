class apps::fbsync_controlflip ( $env='production', $celerytype='mixed' ) {

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

  package { 'devscripts':
    ensure  => installed,
  }

  file { '/var/log/edgeflip':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
  }

  cron {'celery_purge':
    command  => 'cd /var/www/edgeflip && ./bin/python manage.py purge_celery_taskmeta',
    user     => root,
    hour     => 3,
    minute   => 7,
  }
}
