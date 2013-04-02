# trivial class to start ntp on ubuntu systems
#
# $force_step -  ntpd is limited by the kernel to a certain slew rate. If time
# gets really funky from the VM host, NTPD might not be able to keep up.
# ntpd(8) for details. (They site 1 second of slew per 2000s of wall clock as a rule
# of thumb.)
#
# FIXME: $force_step is currently an no-op, hoever may come in handy in the
# future. eg, I've read that adding '-x' to NTPD_OPTS in /etc/default/ntp may
# help, but the ntp docs seem to contradict this. (See the tinker step option,
# which is related.) I don't think it's needed now, but FAIR WARNING.

class ntp ( $force_step=false ) {

  package { 'ntp':
    ensure => installed,
    #notify => Exec['ntpdate'], #TODO: for this to work, the service must be stopped. :/
  }

  service { 'ntp':
    ensure  => running,
    require => Package['ntp'],
  }

}
