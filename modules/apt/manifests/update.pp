class apt::update {
  include apt

  exec { 'apt-get-update':
    command => '/usr/bin/apt-get update > /var/log/apt/update.log',
    returns => [ 0, 100 ],
    require => [ File['/etc/apt/sources.list.d/geppetto.list'],
                 Exec['import_geppetto_key'],
                 File['/root/.ssh/id_rsa'], ]
  }

}
