# Class: mysql::params
#
# This class holds parameters that need to be
# accessed by other classes.
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class mysql::params{
  $socket                   = '/var/run/mysqld/mysqld.sock'
  case $operatingsystem {
    'centos', 'redhat', 'fedora': {
      $service_name         = 'mysqld'
      $client_package_name  = 'mysql'
    }
    'ubuntu', 'debian': {
      $service_name         = 'mysql'
      $client_package_name  = 'mysql-client-5.1'
      $ruby_package_name    = 'ruby-mysql'
      $php_package_name     = 'php5-mysql'
    }
    default: {
      $python_package_name  = 'python-mysqldb'
      $ruby_package_name    = 'ruby-mysql'
      $php_package_name     = 'php5-mysql'
      $client_package_name  = 'mysql'
    }
  }
}
