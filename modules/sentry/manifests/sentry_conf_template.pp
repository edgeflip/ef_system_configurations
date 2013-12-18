define sentry::sentry_conf_template (
    $dbname, $dbuser, $dbpass, $dbhost, $dbport, $url, $port, 
    $server_email, $secret_key) {

    file { "/etc/$name.conf.py":
        ensure  => file,
        content => template('sentry/sentry/sentry.conf.py.erb'),
    }
}
