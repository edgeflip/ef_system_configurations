# usage class memcached { port => 11211, cachesize => 64, slabsize => "1m", logfile => "/var/log/memcached.log", hostaddress => "127.0.0.1" }

class memcached( $port=11211, $cachesize=64, $slabsize="1m", $logfile="/var/log/memcached.log", $hostaddress="127.0.0.1" ) {

  package { memcached:
    ensure => latest
  }

  file { "/etc/memcached.conf":
    mode => "644",
    require => Package["memcached"],
    content => template("memcached/memcached.conf.erb"),
    notify  => Service['memcached'],
  }

  service { "memcached":
    enable => true,
    ensure => running,
    hasrestart => true,
    hasstatus => true,
    require => Package["memcached"],
    status => "/etc/init.d/memcached status",
  }
}
