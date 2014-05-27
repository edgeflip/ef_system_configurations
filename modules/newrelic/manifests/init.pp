class newrelic {

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

  package { 'newrelic-sysmond':
    ensure  => latest,
    require => [ Exec['import-newrelic-apt-key'], ],
  }

  service { 'newrelic-sysmond':
    ensure    => running,
    enable    => true,
    hasstatus => true,
    require   => [
        Package['newrelic-sysmond'], File['/etc/newrelic/nrsysmond.cfg']
    ],
  }

  file { '/etc/newrelic/nrsysmond.cfg':
    mode    => '0644',
    owner   => root,
    require => Package['newrelic-sysmond'],
    notify  => Service['newrelic-sysmond'],
    source  => 'puppet:///modules/newrelic/nrsysmond.cfg',
  }

}
