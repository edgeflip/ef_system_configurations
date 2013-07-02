class apps::edgeflipcelery ( $env='production' ) {

  case $env {
    'production': {
      $edgeflipcelery_env='production'
      $edgeflipcelery_hostname='www.edgeflipcelery.com'
    } 'staging': {
      $edgeflipcelery_env='staging'
      $edgeflipcelery_hostname='edgeflipcelery.efstaging.com'
    }
  }

  apache2::templatevhost { "$edgeflipcelery_hostname":
    content => template('apps/edgeflipcelery/vhost.erb'),
    require => Package['edgeflipcelery'],
  }

  package { 'edgeflipcelery':
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

  file { '/opt/fix-perms.sh':
    ensure  => file,
    mode    => "0755",
    source  => 'puppet:///modules/apps/edgeflipcelery/fix-perms.sh',
  }

  file { '/var/www/edgeflipcelery/newrelic.ini':
    ensure  => file,
    mode    => "0755",
    source  => '/root/creds/app/celery/newrelic.ini',
    owner   => 'www-data',
    group   => 'www-data',
    notify  => Service['apache2'],
    require => Package['edgeflipcelery'],
  }

  exec { 'move_configs':
    command     => '/usr/bin/sudo /bin/cp /root/creds/app/celery/* /var/www/edgeflipcelery/edgeflip/conf.d/',
    refreshonly => true,
    require     => Package['edgeflipcelery'],
    notify      => [ Service['apache2'], Exec['fix_perms'], ]
  }

  # Celery related items
  group { 'celery':
    system  => true,
  }

  user { 'celery':
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

  file { '/etc/default/celeryd':
    ensure  => file,
    source  => '/var/www/edgeflipcelery/scripts/celeryd.conf',
    require => [ Package['edgeflipcelery'],
                 Package['rabbitmq-server'], ],
    notify  => Service['celeryd'],
  }

  file { "/etc/init.d/celeryd":
    ensure  => link,
    target  => "/var/www/edgeflipcelery/scripts/celery/celeryd",
    require => [ Package['rabbitmq-server'],
                 Package['edgeflipcelery'], ],
    notify  => Service['celeryd'],
  }

  file { '/etc/default/celeryd':
    ensure  => file,
    source  => '/var/www/edgeflipcelery/scripts/celeryd.conf',
    require => [ Package['edgeflipcelery'],
                 Package['rabbitmq-server'], ],
    notify  => Service['celeryd'],
  }

  service { 'celeryd':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    subscribe  => Service['rabbitmq-server'],
    status     => "/etc/init.d/celeryd status",
  }

  exec { 'fix_perms':
    command     => '/opt/fix-perms.sh',
    refreshonly => true,
    require     => [ Package['edgeflipcelery'],
                     File['/opt/fix-perms.sh'] ],
    notify      => Service['apache2'],
  }

  rsyslog::importconfig { 'edgeflipcelery':
    source => 'puppet:///modules/apps/edgeflipcelery/rsyslog.conf',
  }
}
