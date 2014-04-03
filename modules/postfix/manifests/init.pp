class postfix {

    package { 'postfix':
        ensure => installed
    }

    file { 'postfix_config':
        ensure  => file,
        path    => '/etc/postfix/main.cf',
        source  => 'puppet:///modules/postfix/postfix/main.cf',
        require => [ Package['postfix'] ]
    }

    service { 'postfix':
      ensure     => running,
      hasstatus  => true,
      hasrestart => true,
      status     => '/etc/init.d/postfix status',
      subscribe  => File['postfix_config'],
    }

}
