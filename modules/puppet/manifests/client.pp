# a puppet client class, to standardize Puppet config after cloud-init / vagrant
#
# $nodename and $nodetype are currently unused, and are intended as placeholders
# for the node-longrandomstring name, with $nodename defaulting to a GUID suffix
#
class puppet::client( $nodetype='', $nodename='', $runinterval=1800, $server='') {
  include rsyslog

  package { 'puppet':
    ensure => present,
  }


  service { 'puppet':
#   ensure     => running, # disabled, puppet makes a terrible zombie
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
    require    => Package['puppet'],
  }

  rsyslog::importconfig { 'puppet':
    source => 'puppet:///modules/puppet/rsyslog.conf'
  }
}