class creds::wipe {

  exec { 'wipe_node_creds':
    command => '/bin/rm -rf /root/creds',
    onlyif  => '/bin/ls -1 /root/creds',
  }

}
