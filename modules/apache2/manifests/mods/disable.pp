define apache2::mods::disable ( ) {

    exec { "disable_${name}":
      command => "/usr/sbin/a2dismod ${name}",
      onlyif  => "/usr/sbin/apache2ctl -t -D DUMP_MODULES | /bin/grep ${name}_module",
      require => Package['apache2'],
      notify  => Service['apache2'],
    }
}
