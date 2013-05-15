class newrelic::server-agent {

  package { "newrelic-sysmond":
    ensure => latest,
  }

  service { "newrelic-sysmond":
    enable    => true,
    ensure    => running,
    hasstatus => true,
    require   => [ Package["newrelic-sysmond"], File["/etc/newrelic/nrsysmond.cfg"] ],
  }

  file { "/etc/newrelic/nrsysmond.cfg":
    mode    => 644,
    owner   => root,
    require => Package['newrelic-sysmond'],
    notify  => Service['newrelic-sysmond'],
    source  => 'puppet:///modules/newrelic/nrsysmond.cfg',
  }

}