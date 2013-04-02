class locale {

  exec { 'locale-gen':
    command  => '/usr/sbin/locale-gen en_US.UTF-8',
  }

}
