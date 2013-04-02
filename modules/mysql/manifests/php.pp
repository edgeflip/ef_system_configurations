# Class: mysql::php
#
# This class installs the php libs for mysql.
#
# Parameters:
#   [*ensure*]       - ensure state for package.
#                        can be specified as version.
#   [*package_name*] - name of package
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class mysql::php(
  $ensure = installed,
  $package_name = $mysql::params::python_package_name
) inherits mysql::params {

  include apache2

  package { 'php5-mysql':
    name => $package_name,
    ensure => $ensure,
    notify => [ Service['apache2'], Service['php5-fpm'] ]
  }
}
