# logging::init -
#
# This module is designed to be standalone so it can be used in a
#   prep stage, while avoiding circular dependancies.

class logging ( $ship_logs=true ) {

#  if $ship_logs {
#    Well, then we'll put something here, won't we?
#  }

  file { '/opt/ef/logging':
    ensure => directory,
    owner  => root,
    mode   => 0755,
  }

  file { '/etc/rsyslog.conf':
    ensure => present,
    mode   => 0644,
    source => 'puppet:///modules/logging/rsyslog.conf',
    notify => Exec['reload_rsyslog'],
  }

  file { '/etc/rsyslog.d/50-default.conf':
    ensure => present,
    owner  => root,
    source => 'puppet:///modules/logging/50-default.conf',
    notify => Exec['reload_rsyslog'],
  }

  # rotate all logs in /var/log/ef daily
  file { '/etc/logrotate.d/ef':
    ensure => present,
    owner  => root,
    source => 'puppet:///modules/logging/ef-rotate.conf',
  }

  # used instead of rsyslog service to avoid circular dep when this is used in
  # prep stage
  exec { 'reload_rsyslog':
    command     => '/sbin/restart rsyslog',
    refreshonly => true,
  }



}
