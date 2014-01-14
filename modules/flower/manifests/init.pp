class flower ($venv_path = '/var/www/flower') {

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
        source  => 'puppet:///modules/flower/flower/requirements.txt',
        require => [ Exec['build_venv'] ]
    }

    exec { 'install_flower':
        command => "$venv_path/bin/pip install -r $venv_path/requirements.txt",
        require => [ File['requirements'] ]
    }

    supervisor::template_supervisor_conf { 'flower_prod': 
        appname   => 'flower',
        directory => "$venv_path",
        command   => "$venv_path/bin/celery flower --broker=amqp://edgeflip:edgeflip@eflip-rmq.efprod.com:5672/edgehost",
    }

    flower::apache_conf_template { 'flower_prod_apache_conf': 
        hostname => 'flower.efprod.com',
        port     => '5555'
    }
}
