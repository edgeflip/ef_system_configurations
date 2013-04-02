class s3cmd {

  package {'s3cmd':
    ensure  => latest,
    require => Class['apt::update'],
  }

  file { '/root/.s3cfg':
    ensure  => present,
    source  => 'puppet:///modules/s3cmd/s3cfg',
    mode    => 0600,
    replace => no,
  }

  exec { 'append_s3_key':
    command => '/bin/cat /root/.s3cfg-creds >> /root/.s3cfg',
    unless  => '/bin/grep access_key /root/.s3cfg',
    require => [ File['/root/.s3cfg'],
                 Class['Creds'], ], #NEW
  }

}
