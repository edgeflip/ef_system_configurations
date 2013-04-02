define upstart::job ( $source='', $content='', $ensure_job='running' ) {

  if $source {
    file { "/etc/init/$name.conf":
      ensure => present,
      source => $source,
      notify => Service["$name"]
    }
  } elsif $content {
    file { "/etc/init/$name.conf":
      ensure  => present,
      content => $content,
      notify  => Service["$name"]
    }
  }

  file { "/etc/init.d/$name":
    ensure  => link,
    target  => '/lib/init/upstart-job',
    require => File["/etc/init/$name.conf"],
  }

  service { "$name":
    ensure     => $ensure_job,
    hasstatus  => true,
    require    => File["/etc/init.d/$name"]
  }

}
