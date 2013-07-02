class rabbitmq ( $newuser='edgeflip', $newpass='edgeflip', $newvhost='edgeflip' ) {

  package { 'rabbitmq-server':
    ensure => installed,
    notify => Exec['add-new-user'],
  }

  service { 'rabbitmq-server':
    ensure  => running,
    require => Package['rabbitmq-server'],
  }

  exec { 'add-new-user':
    command     => '/usr/sbin/rabbitmqctl add_user $newuser $newpass',
    returns     => [ 0, 100 ],
    require     => [ Package['rabbitmq-server'],
                     Service['rabbitmq-server'], ],
    refreshonly => true,
    notify      => Exec['add-new-vhost'],
  }

  exec { 'add-new-vhost':
    command     => '/usr/sbin/rabbitmqctl add_vhost $newvhost',
    returns     => [ 0, 100 ],
    require     => [ Package['rabbitmq-server'],
                     Service['rabbitmq-server'],
                     Exec['add-new-user'], ],
    refreshonly => true,
    notify      => Exec['add-new-permissions'],
  }

  exec { 'add-new-permissions':
    command     => '/usr/sbin/rabbitmqctl set_permissions -p edgehost edgeflip \".*\" \".*\" \".*\"',
    returns     => [ 0, 100 ],
    require     => [ Package['rabbitmq-server'],
                     Service['rabbitmq-server'],
                     Exec['add-new-vhost'], ],
    refreshonly => true,
  }
}
