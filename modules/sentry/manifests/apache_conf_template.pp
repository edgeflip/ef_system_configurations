define sentry::apache_conf_template ( $hostname, $port ) {

    apache2::templatevhost { "$hostname":
        content => template('sentry/sentry/sentry_apache_conf.erb'),
    }
}
