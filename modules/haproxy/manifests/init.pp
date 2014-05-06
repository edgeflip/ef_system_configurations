class haproxy {

    exec { 'add-haproxy-ppa':
        command     => '/usr/bin/add-apt-repository -y ppa:vbernat/haproxy-1.5',
        refreshonly => true,
    }

    package { 'haproxy':
        ensure  => installed,
        require => [ Exec[ 'add-haproxy-ppa' ], ],
    }

    file { 'haproxy-default':
        ensure  => file,
        path    => '/etc/default/haproxy',
        content => 'ENABLED=1',
        require => [ Package['haproxy'], ],
    }

    service { 'haproxy':
        ensure  => running,
        require => [ File['haproxy-default'] ],
    }

    file { 'haproxy-sample':
        ensure  => file,
        path    => '/etc/haproxy/haproxy.cfg.sample',
        source  => 'puppet:///modules/haproxy/haproxy/haproxy.cfg.sample',
        require => [ Package['haproxy'], ],
    }

}
