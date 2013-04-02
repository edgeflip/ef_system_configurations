define apache2::mods::enable ( ) {

    exec { "enable_${name}":
      command => "/usr/sbin/a2enmod ${name}",
      unless  => "/usr/sbin/apache2ctl -t -D DUMP_MODULES | /bin/grep ${name}_module",
      require => Package['apache2'],
      notify  => Service['apache2'],
    }
}
