# Definition: apache2::importvhost
#
# This define imports preconfigured Apache Virtual Hosts
#
# Parameters:
# - The $name name of the vhost located in the apache module files
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
#    name => 'name_of_vhost_file'
#  }
#
#
define apache2::templatevhost ( $content ) {
  include apache2

  file { "/etc/apache2/sites-available/$name":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => 0644,
    content => $content,
    notify  => Service['apache2'],
    require => Package['apache2'],
  }

  file { "/etc/apache2/sites-enabled/$name":
    ensure  => link,
    target  => "/etc/apache2/sites-available/$name",
    require => File["/etc/apache2/sites-available/$name"],
    notify  => Service['apache2'],
  }

}

