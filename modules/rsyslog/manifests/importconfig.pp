# rsyslog::importconfig - add a configuration to rsyslog, typically to filter
# logs to a given file
#
# $priority (default: 30), reduce this value to make a configuration take
# precidence over another.
#
define rsyslog::importconfig ( $source='', $content='',  $priority='30' ) {
  include rsyslog

  if $source {
    file { "/etc/rsyslog.d/${priority}-${name}.conf":
      ensure  => present,
      source  => $source,
      require => Package['rsyslog'],
      notify  => Service['rsyslog'],
    }
  } else {
    file { "/etc/rsyslog.d/${priority}-${name}.conf":
      ensure  => present,
      content => $content,
      require => Package['rsyslog'],
      notify  => Service['rsyslog'],
    }
  }


}
