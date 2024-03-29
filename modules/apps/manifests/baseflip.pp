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
                 Package['libpq-dev'],
                 Package['graphviz'], ],
    notify  => [ Exec['fix_perms'],
                 Exec['move_configs'], ],
  }

  package { 'build-essential':
    ensure  => installed,
  }

  package { 'mysql-client':
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

  package {'libpq-dev':
      ensure => installed,
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
    require => Package['edgeflip'],
  }

  exec { 'move_configs':
    command     => '/usr/bin/sudo /usr/bin/rsync -av /root/creds/app/ /var/www/edgeflip/conf.d/ --delete',
    refreshonly => true,
    require     => [ Package['edgeflip'], File['/var/www/edgeflip/conf.d'], ],
    notify      => Exec['fix_perms']
  }

  exec { 'fix_perms':
    command     => '/opt/fix-perms.sh',
    refreshonly => true,
    require     => [ Package['edgeflip'],
                     File['/opt/fix-perms.sh'] ],
  }

  rsyslog::importconfig { 'edgeflip':
    source => 'puppet:///modules/apps/edgeflip/rsyslog.conf',
  }

}

