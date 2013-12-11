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
        'python-mysqldb'
        ]:
        ensure => installed
    }

    exec { 'create_path':
        command => '/usr/bin/sudo /bin/mkdir -p /var/www && /usr/bin/sudo /bin/chown ubuntu:ubuntu -R /var/www',
    }

    exec { 'build_venv':
        command => '/usr/bin/sudo /usr/bin/virtualenv $venv_path',
        unless  => '/usr/bin/test -d $venv_path',
        require => [ Package['python-virtualenv'], Exec['create_path'] ],
    }

    file { 'requirements':
        ensure  => file,
        path    => '$venv_path/requirements.txt',
        source  => 'puppet:///modules/apps/sentry/requirements.txt',
        require => [ Exec['build_venv'] ]
    }

    exec { 'install_sentry':
        command => '/var/www/sentry/bin/pip install -r $venv_path/requirements.txt',
        require => [ File['requirements'] ]
    }
}
