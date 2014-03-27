class apps::controlflip ( $env='production', $celerytype='mixed' ) {

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

  cron { 'ofa_token_sync':
    command  => "cd /var/www/edgeflip && /usr/bin/annotate-output ./bin/python manage.py synctokens --database=ofa --model=OFAToken --clientid=19 --since=1d >> /var/log/edgeflip/synctokens.log 2>&1",
    user     => root,
    hour     => 0,
    minute   => 7,
  }
}
