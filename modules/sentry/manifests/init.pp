class sentry ($venv_path = '/var/www/sentry') {

    package { [
        #'build-essential',
        'python-pip',
        'python-virtualenv',
        #'virtualenvwrapper',
        #'libmysqlclient-dev',
        #'gcc',
        #'python-dev',
        #'python-mysqldb',
        'postfix',
        #'mysql-client-core-5.5',
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
        source  => 'puppet:///modules/sentry/sentry/requirements.txt',
        require => [ Exec['build_venv'] ]
    }

    exec { 'install_sentry':
        command => "/var/www/sentry/bin/pip install -r $venv_path/requirements.txt",
        require => [ File['requirements'] ]
    }

    supervisor::template_supervisor_conf { 'staging_supervisor': 
        appname   => 'sentry-web-staging',
        directory => '/var/www/sentry',
        command   => '/var/www/sentry/bin/sentry --config=/etc/sentry_staging.conf.py start http',
    }

    supervisor::template_supervisor_conf { 'prod_supervisor': 
        appname   => 'sentry-web',
        directory => '/var/www/sentry',
        command   => '/var/www/sentry/bin/sentry --config=/etc/sentry.conf.py start http',
    }

    sentry::apache_conf_template { 'staging_apache_conf': 
        hostname => 'sentry.efstaging.com',
        port     => '9090'
    }

    sentry::apache_conf_template { 'prod_apache_conf': 
        hostname => 'sentry.efprod.com',
        port     => '9000'
    }

    sentry::sentry_conf_template { 'staging_sentry':
        dbname       => 'sentry_staging',
        dbuser       => 'sentry_staging',
        dbpass       => 'xnXxefeu8oT4TR',
        dbhost       => 'sentry-db.efstaging.com',
        dbport       => 3306,
        url          => 'sentry.efstaging.com',
        port         => 9090,
        server_email => 'sentry+staging@localhost',
        secret_key   => '664BhTrE4mkz80O/qWtbfFQgI5FZwkiSWGXI8CE+HFiqjZty0tV9aw=='
    }

    sentry::sentry_conf_template { 'sentry':
        dbname       => 'sentry_prod',
        dbuser       => 'sentry',
        dbpass       => 'tVZjigd3ZBon3B',
        dbhost       => 'sentry-db.efprod.com',
        dbport       => 3306,
        url          => 'sentry.efprod.com',
        port         => 9000,
        server_email => 'sentry+prod@localhost',
        secret_key   => 'tWCZVg+dwVBsnbldhX0nA6fG62wBAF+Gz39FK6L4JQsXJozZxZa2gA=='
    }


}
