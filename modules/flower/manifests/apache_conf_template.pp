define sentry::apache_conf_template ( $hostname, $port ) {

    apache2::templatevhost { "$hostname.conf":
        content => template('flower/flower/flower_apache_conf.erb'),
    }
}
