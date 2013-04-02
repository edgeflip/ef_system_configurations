class roles::logger {
  include rsyslog
  include users

  # you get logs! and you get logs! everybody! gets! LOGS!
  Users::Account<|  |>

  rsyslog::importconfig { 'receiver':
    priority => 45,
    source   => 'puppet:///modules/roles/logger/receiver.conf',
  }

  define filterset ( ) {
    $log_env = $title
    rsyslog::importconfig { "$log_env":
      content  => template('roles/logger/remote-ruleset.conf.erb'),
      priority => 40,
    }
  }

  filterset { 'staging': }
  filterset { 'production': }

  #rotate log files
  file { '/etc/logrotate.d/ef-remote':
    ensure => present,
    owner  => root,
    source => 'puppet:///modules/roles/logger/ef-rotate.conf',
  }

}
