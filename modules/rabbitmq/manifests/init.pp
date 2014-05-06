class rabbitmq ( $newuser='edgeflip', $newpass='edgeflip', $newvhost='edgeflip' ) {

  package { 'rabbitmq-server':
    ensure  => installed,
    notify  => Exec['add_new_user'],
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

  file { '/var/lib/rabbitmq/logs':
      ensure  => directory,
      require => [ Package['rabbitmq-server'], ],
  }

  file { '/etc/default/rabbitmq-server':
      ensure  => file,
      source  => 'puppet:///modules/rabbitmq/rabbitmq/rabbitmq-defaults',
      require => [
        Package['rabbitmq-server'],
        File['/var/lib/rabbitmq/logs'],
      ],
      notify  => [ Service['rabbitmq-server'], ],
  }

  file { '/etc/rabbitmq/rabbitmq.config':
      ensure  => file,
      source  => 'puppet:///modules/rabbitmq/rabbitmq/rabbitmq.config',
      require => [
        Package['rabbitmq-server'],
        File['/var/lib/rabbitmq/logs'],
      ],
      notify  => [ Service['rabbitmq-server'], ],
  }

  file { '/etc/init.d/rabbitmq-server':
      ensure  => file,
      mode    => '0755',
      source  => 'puppet:///modules/rabbitmq/rabbitmq/rabbitmq-server.init',
      require => [
        Package['rabbitmq-server'],
        File['/etc/rabbitmq/rabbitmq.config'],
        File['/etc/default/rabbitmq-server'],
      ],
      notify => [ Service['rabbitmq-server'], ],
  }

  exec { 'add_new_user':
    command     => "/usr/sbin/rabbitmqctl add_user $newuser $newpass",
    returns     => [ 0, 100 ],
    require     => [
      Package['rabbitmq-server'],
      Service['rabbitmq-server'],
    ],
    refreshonly => true,
    notify      => Exec['add_new_vhost'],
  }

  exec { 'add_new_vhost':
    command     => "/usr/sbin/rabbitmqctl add_vhost $newvhost",
    returns     => [ 0, 100 ],
    require     => [
      Package['rabbitmq-server'],
      Service['rabbitmq-server'],
      Exec['add_new_user'],
    ],
    refreshonly => true,
    notify      => Exec['add_new_permissions'],
  }

  exec { 'add_new_permissions':
    command     => "/usr/sbin/rabbitmqctl set_permissions -p $newvhost $newuser \".*\" \".*\" \".*\"",
    returns     => [ 0, 100 ],
    require     => [
      Package['rabbitmq-server'],
      Service['rabbitmq-server'],
      Exec['add_new_vhost'],
    ],
    refreshonly => true,
  }

  exec { 'add_admin_user':
    command => '/usr/sbin/rabbitmqctl add_user admin 303ewacker',
    returns => [ 0, 100 ],
    require => [
      Package['rabbitmq-server'],
      Service['rabbitmq-server'],
      Exec['add_new_permissions'],
    ],
  }

  exec { 'grant_admin_privs':
    command => '/usr/sbin/rabbitmqctl set_user_tags admin administrator',
    returns => [ 0, 100 ],
    require => [
      Package['rabbitmq-server'],
      Service['rabbitmq-server'],
      Exec['add_admin_user'],
    ],
  }
}
