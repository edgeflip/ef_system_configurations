class apt($staging = false) {
  include creds

  file { '/root/.ssh':
    ensure  => directory,
  }

  file { '/root/.ssh/id_rsa':
    ensure  => present,
    source  => '/root/creds/id_rsa.deploy',
    mode    => 0600,
    owner   => 'root',
    require => [ File['/root/.ssh'], Class['creds'], ]
 }

  file { '/etc/apt/sources.list.d/geppetto.list':
    ensure  => present,
    content => template('apt/geppetto.list.erb'),
  }

  file { '/etc/apt/sources.list.d/ubuntu_repos.list':
      ensure => present,
      source => 'puppet:///modules/apt/ubuntu_repos.list',
      notify => [Exec['apt-get-update'], ],
  }

  file { '/etc/apt/sources.list.d/rabbitmq.list':
    ensure  => present,
    content => 'deb http://www.rabbitmq.com/debian/ testing main'
  }

# TODO I hate this.  Fix.
  exec { 'import_geppetto_key':
    command => '/usr/bin/wget -O - http://geppetto.efprod.com/ef.apt.public.key | /usr/bin/apt-key add - ',
  }

  exec { 'import_rabbit_key':
    command => '/usr/bin/wget -O - http://www.rabbitmq.com/rabbitmq-signing-key-public.asc | /usr/bin/apt-key add - ',
    require => [ File['/etc/apt/sources.list.d/rabbitmq.list'], ],
    notify  => [ Exec['apt-get-update'], ],
  }

  file { 'newrelic-apt-repo':
      ensure  => file,
      path    => '/etc/apt/sources.list.d/newrelic.list',
      content => 'deb http://apt.newrelic.com/debian/ newrelic non-free',
      mode    => '0644',
      owner   => root,
  }

  exec { 'import-newrelic-apt-key':
    command => '/usr/bin/wget -O- https://download.newrelic.com/548C16BF.gpg | /usr/bin/apt-key add -',
    require => [ File['newrelic-apt-repo'], ],
    notify  => [ Exec['apt-get-update'], ],
  }

}
