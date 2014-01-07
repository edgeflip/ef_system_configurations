class rabbitmq ( $newuser='edgeflip', $newpass='edgeflip', $newvhost='edgeflip' ) {

  package { 'rabbitmq-server':
    ensure => installed,
    notify => Exec['add_new_user'],
  }

  service { 'rabbitmq-server':
    ensure  => running,
    require => Package['rabbitmq-server'],
  }

  file { '/etc/rabbitmq/enabled_plugins':
      ensure  => file,
      content => '[rabbitmq_management].',
      require => [ Package['rabbitmq-server'], ],
      notify  => [ Service['rabbitmq-server'], ],
  }

  file { '/etc/rabbitmq/rabbitmq.conf.d':
      ensure  => directory,
      require => [ Package['rabbitmq-server'], ],
  }

  exec { 'add_new_user':
    command     => "/usr/sbin/rabbitmqctl add_user $newuser $newpass",
    returns     => [ 0, 100 ],
    require     => [ Package['rabbitmq-server'],
                     Service['rabbitmq-server'], ],
    refreshonly => true,
    notify      => Exec['add_new_vhost'],
  }

  exec { 'add_new_vhost':
    command     => "/usr/sbin/rabbitmqctl add_vhost $newvhost",
    returns     => [ 0, 100 ],
    require     => [ Package['rabbitmq-server'],
                     Service['rabbitmq-server'],
                     Exec['add_new_user'], ],
    refreshonly => true,
    notify      => Exec['add_new_permissions'],
  }

  exec { 'add_new_permissions':
    command     => "/usr/sbin/rabbitmqctl set_permissions -p edgehost edgeflip \".*\" \".*\" \".*\"",
    returns     => [ 0, 100 ],
    require     => [ Package['rabbitmq-server'],
                     Service['rabbitmq-server'],
                     Exec['add_new_vhost'], ],
    refreshonly => true,
  }
}
