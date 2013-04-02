class apache2::dev {

  $apache_dev_packages = [ 'libaprutil1-dev', 'libapr1-dev',
  'apache2-prefork-dev', 'libcurl4-openssl-dev', 'libssl-dev', 'zlib1g-dev' ]

  package{$apache_dev_packages: 
    ensure => installed
  }

}
