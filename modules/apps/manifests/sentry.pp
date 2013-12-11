class apps::sentry {

    $venv_path = '/var/www/sentry'
    package { [
        'build-essential',
        'python-pip',
        'python-virtualenv',
        'virtualenvwrapper',
        'libmysqlclient-dev',
        'gcc',
        'python-dev',
        'python-mysqldb',
        'postfix',
        'mysql-client-core-5.5',
        'supervisor'
        ]:
        ensure => installed
    }

    exec { 'create_path':
        command => '/usr/bin/sudo /bin/mkdir -p /var/www && /usr/bin/sudo /bin/chown ubuntu:ubuntu -R /var/www',
    }

    exec { 'build_venv':
        command => "/usr/bin/sudo /usr/bin/virtualenv $venv_path && $venv_path/bin/easy_install -U distribute",
        unless  => "/usr/bin/test -d $venv_path",
        require => [ Package['python-virtualenv'], Exec['create_path'] ],
    }

    file { 'requirements':
        ensure  => file,
        path    => "$venv_path/requirements.txt",
        source  => 'puppet:///modules/apps/sentry/requirements.txt',
        require => [ Exec['build_venv'] ]
    }

    exec { 'install_sentry':
        command => "/var/www/sentry/bin/pip install -r $venv_path/requirements.txt",
        require => [ File['requirements'] ]
    }

    file { 'staging_sentry_conf':
        ensure => file,
        path   => '/etc/sentry_staging.conf.py',
        source => 'puppet:///modules/apps/sentry/staging_sentry.conf.py',
    }

    file { 'sentry_conf':
        ensure => file,
        path   => '/etc/sentry.conf.py',
        source => 'puppet:///modules/apps/sentry/prod_sentry.conf.py',
    }

    file { 'staging_supervisor':
        ensure  => file,
        path    => '/etc/supervisor/conf.d/staging_sentry.conf',
        source  => 'puppet:///modules/apps/sentry/staging_sentry_supervisor.conf',
        require => [ Exec['install_sentry'], Package['supervisor'], File['staging_sentry_conf'] ],
        notify  => [ Service['supervisor'] ]
    }

    file { 'prod_supervisor':
        ensure  => file,
        path    => '/etc/supervisor/conf.d/sentry.conf',
        source  => 'puppet:///modules/apps/sentry/prod_sentry_supervisor.conf',
        require => [ Exec['install_sentry'], Package['supervisor'], File['sentry_conf'] ],
        notify  => [ Service['supervisor'] ]
    }

    service { 'supervisor':
      ensure     => running,
      hasstatus  => true,
      hasrestart => true,
      status     => "/etc/init.d/supervisor status",
    }

    file { '/etc/apache2/sites-available/staging_apache_conf':
        ensure  => file,
        path    => '/etc/apache2/sites-available/staging_sentry.conf',
        source  => 'puppet:///modules/apps/sentry/staging_sentry_apache.conf',
        require => [ Package['apache2'] ]
    }

    file { '/etc/apache2/sites-enabled/staging_apache.conf':
        ensure  => link,
        target  => '/etc/apache2/sites-available/staging_sentry.conf',
        require => File['/etc/apache2/sites-available/staging_apache_conf'],
        notify  => Service['apache2']
    }

    file { '/etc/apache2/sites-available/prod_apache_conf':
        ensure  => file,
        path    => '/etc/apache2/sites-available/prod_sentry.conf',
        source  => 'puppet:///modules/apps/sentry/prod_sentry_apache.conf',
        require => [ Package['apache2'] ]
    }

    file { '/etc/apache2/sites-enabled/prod_apache.conf':
        ensure  => link,
        target  => '/etc/apache2/sites-available/prod_sentry.conf',
        require => File['/etc/apache2/sites-available/prod_apache_conf'],
        notify  => Service['apache2']
    }
}