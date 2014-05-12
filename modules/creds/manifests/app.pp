class creds::app ( $env='staging', $app='geppetto',
                   $bucket='s3://ef-techops/creds/apps' ){

  $s3cfg = '/root/.s3cfg-creds'
  $source = "$bucket/$env/$app/"

  file { '/root/creds/app':
    ensure  => directory,
    owner   => root,
    group   => root,
    mode    => '0700',
    notify  => Exec['get_app_creds'],
    require => [
        File['/root/creds'],
        Exec['install_s3cmd'],
        File['/root/.s3cfg-creds']
    ],
  }

  exec { 'get_app_creds':
    command     => "/usr/bin/s3cmd get --recursive --force -c ${s3cfg} ${source} /root/creds/app",
    require     => [ Exec['install_s3cmd'], File['/root/creds/app'], File['/root/.s3cfg-creds'], ],
    notify      => Exec['inject_authorized_sshkeys'],
  }

  exec { 'inject_authorized_sshkeys':
    command  => "/bin/cat /root/creds/app/authorized_sshkeys >> /home/ubuntu/.ssh/authorized_keys",
    require  => Exec['get_app_creds'],
    unless      => "/bin/grep specific /home/ubuntu/.ssh/authorized_keys",
    refreshonly => true,
    }
}
