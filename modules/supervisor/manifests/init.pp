class supervisor {

    package { 'supervisor':
        ensure => installed
    }

    service { 'supervisor':
      ensure     => running,
      hasstatus  => true,
      hasrestart => true,
      status     => "/etc/init.d/supervisor status",
      require    => Package['supervisor'],
    }
}
