define creds::fetch( $owner='root', $group='root', $bucket='s3://ef-techops/creds/deployment', $destination, $mode=0600 ) {

  $s3cfg = '/root/.s3cfg-creds'

  exec { "get_$name":
    command => "/usr/bin/s3cmd --force -c $s3cfg get $bucket/$name $destination",
  }

  file { "$destination":
    ensure  => present,
    owner   => $owner,
    group   => $group,
    mode    => $mode,
    require => Exec["get_$name"],
  }

}
