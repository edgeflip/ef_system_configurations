class apt($staging = false) {
  include creds

  file { '/root/.ssh':
    ensure  => directory,
  }

  file { '/root/.ssh/id_rsa':
    ensure  => present,
    source  => '/root/creds/id_rsa.deploy',
    mode    => 0600,
    owner   => 'root',
    require => [ File['/root/.ssh'], Class['creds'], ]
 }

  file { '/etc/apt/sources.list.d/geppetto.list':
    ensure  => present,
    content => template('apt/geppetto.list.erb'),
  }

# TODO I hate this.  Fix.
  exec { 'import_geppetto_key':
  command => '/usr/bin/wget -O - http://geppetto.efprod.com/ef.apt.public.key | /usr/bin/apt-key add - ',
  }


}
