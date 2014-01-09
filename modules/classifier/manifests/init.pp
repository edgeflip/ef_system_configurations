class classifier {
    
    package { 'uuid-dev':
        ensure => installed,
    }

    package { 'dmoz':
        ensure  => installed,
        require => [Package['uuid-dev']],
    }

    supervisor::template_supervisor_conf { 'classifier': 
        appname   => 'classifier',
        directory => '/opt/',
        command   => '/usr/bin/dmozClassifyServer -ibow:/usr/lib/Top.Bow -ipart:/usr/lib/Top.BowPart -port:8080'
    }
}
