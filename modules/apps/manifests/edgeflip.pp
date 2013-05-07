class apps::edgeflip ( $env='production' ) {

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

  package { 'edgeflip':
    ensure  => latest,
    require => [ Package['python-pip'],
                 Package['python-dev'],
                 Package['gcc'],
                 Package['python-mysqldb'] ],
    notify  => [ Exec['fix_perms'], Exec['move_configs'], ],
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
    source  => 'puppet:///modules/apps/edgeflip/fix-perms.sh',
  }

  exec { 'move_configs':
    command     => '/usr/bin/sudo /bin/cp /root/creds/app/* /var/www/edgeflip/edgeflip/conf.d/',
    refreshonly => true,
    require     => Package['edgeflip'],
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
