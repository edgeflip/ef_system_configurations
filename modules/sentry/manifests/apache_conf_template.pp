define sentry::apache_conf_template ( $hostname, $port ) {

    apache2::templatevhost { "$hostname.conf":
        content => template('sentry/sentry/sentry_apache_conf.erb'),
    }
}
