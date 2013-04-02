# Definition: apache2::importvhost
#
# This define imports preconfigured Apache Virtual Hosts
#
# Parameters:
# - The $definedvhost name of the vhost located in the apache module files
# - The $sitename is the FQDN of the hosted site
#
# Actions:
# - Import a preconfigured Apache Virtual Host
#
# Requires:
# - The apache2 class
#
# Sample Usage:
#  apache2::importvhost { 'site.example.com':
#    definedvhost => 'name_of_vhost_file'
#  }
#
#
define apache2::importvhost ( $definedvhost ) {
  include apache2

  file { "/etc/apache2/sites-available/$definedvhost":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => 0644,
    source  => "puppet:///modules/apache2/vhosts/$definedvhost",
    notify  => Service['apache2'],
    require => Package['apache2'],
  }

  file { "/etc/apache2/sites-enabled/$name":
    ensure  => link,
    target  => "/etc/apache2/sites-available/$definedvhost",
    require => File["/etc/apache2/sites-available/$definedvhost"],
    notify  => Service['apache2'],
  }

}

