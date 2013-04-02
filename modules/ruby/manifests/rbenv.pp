class ruby::rbenv {

  package { 'rbenv':
    ensure => latest,
  }

  package { 'rbenv-ruby':
    ensure  => latest,
    require => Package['rbenv'],
    notify  => Exec['rehash_rbenv_shims'],
  }

  exec { 'rehash_rbenv_shims':
    environment => 'RBENV_ROOT=/opt/rbenv',
    command     => '/opt/rbenv/bin/rbenv rehash > /tmp/rbenv-rehash.out',
    refreshonly => true
  }

}
