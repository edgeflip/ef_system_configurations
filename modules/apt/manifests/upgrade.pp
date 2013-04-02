class apt::upgrade {
    include apt::update

        exec { 'apt-get-upgrade':
                command     => '/usr/bin/apt-get upgrade',
                require     => Exec['apt-get-update'],
                refreshonly => true,
        }

}
