class users::keys {

  exec { 'inject_devops_authorized_keys':
    command     => "/bin/cat /root/creds/authorized_keys.mofo >> /home/ubuntu/.ssh/authorized_keys",
    unless      => "/bin/grep 8IYEi453ZJTGM8iEBWsx5Mix0047Ez8ZElH /home/ubuntu/.ssh/authorized_keys",
    require     => Class['creds'],
  }

}
