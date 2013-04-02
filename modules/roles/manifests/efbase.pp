# a base class to handle common shared config on  servers.
#
class roles::efbase ( $production=true ) {
  include s3cmd
  include ruby::gems

  file { '/opt/ef':
    ensure => directory,
    owner  => root,
    group  => admin,
    mode   => 0755,
  }

  file { '/opt/ef/etc':
    ensure  => directory,
    owner   => root,
    group   => admin,
    mode    => 0755,
    require => File['/opt/ef'],
  }

  file { '/var/log':
    ensure  => directory,
    owner   => root,
    group   => admin,
    mode    => 0766,
  }

}
