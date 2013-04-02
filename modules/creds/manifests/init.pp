# For distribution of mofo credentials

# .s3cfg.creds should already exist by the time this command is run

# Bootstrap workflow:
# 1. s3cfg is obtained from a public source
# 2. vagrant/cloud-init append the secret keys
# 3. other applications can either request a cred class, use a custom
# request (using parameterized define), or just snag a local copy from
# /root/creds

class creds {

  $s3cfg = '/root/.s3cfg-creds'
  $source = 's3://mofo-techops/creds/deployment/'

  file { '/root/creds':
    ensure => directory,
    mode   => 0700,
    notify => Exec['get_all'],
  }

  #file should already exist by this point, just changing permissions
  file { '/root/.s3cfg-creds':
    ensure  => file,
    mode    => 0600,
    require => File['/root/creds'],
  }


  exec { 'install_s3cmd':
    command     => "/usr/bin/apt-get -y -q install s3cmd #> /tmp/s3install.log",
    environment => ['DEBIAN_FRONTEND=noninteractive'],
    unless      => '/usr/bin/which s3cmd',
  }

  exec { 'get_all':
    command     => "/usr/bin/s3cmd get --recursive --force -c ${s3cfg} ${source} /root/creds/",
    require     => [ Exec['install_s3cmd'], File['/root/creds'], ],
    refreshonly => true,
  }

}
