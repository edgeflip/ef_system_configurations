class creds::aptrepo {

  $private_key = '/root/creds/ef.apt.key'

  creds::fetch { "creds/deployment/ef.apt.key":
    destination => '/root/creds/ef.apt.key',
    owner       => root,
    group       => root,
  }

#TODO: run this for the ubuntu user as well if in ec2
  exec { 'import_signing_key':
    command => "/usr/bin/gpg --import $private_key",
    unless  => "/usr/bin/gpg -K | /bin/grep somekey",
    require => File['/root/creds/ef.apt.key'],
  }

}
