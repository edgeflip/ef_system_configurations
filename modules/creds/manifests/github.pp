class creds::github ( $user = 'ubuntu' ){

  $ssh_keys_dir = "/home/$user/.ssh"

  file { "$ssh_keys_dir/id_rsa":
    ensure => file,
    owner  => $user,
    group  => $user,
    mode   => 0600,
    source => '/root/creds/id_rsa_github',
  }

}
