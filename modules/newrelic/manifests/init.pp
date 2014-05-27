# Installs and activates NewRelic monitoring service
class newrelic {

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
