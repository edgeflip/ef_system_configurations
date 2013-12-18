class supervisor::template_supervisor_conf ( $appname, $directory, $command, 
    $autostart = 'true', $autorestart = 'true', $redirect_stderr = 'true') {

    file { "/etc/supervisor/conf.d/$name":
        ensure  => file,
        content => template('supervisor/supervisor/supervisor_conf.erb'),
        require => [Package['supervisor'], Service['supervisor']],
        notify  => Service['supervisor'],
    }
}
