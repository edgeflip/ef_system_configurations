class apache2::ruby ( $ruby='1.8.7', $passengerversion='2.2.11debian-2' ) {
#  include mysql
#  include mysql::ruby
#  include ruby::gems
#  $apache2_ruby_package = [ 'rails', 'libapache2-mod-passenger' ]



  case $ruby {
    '1.8.7': {
      $passenger_ruby = '/usr/bin/ruby'
      $passenger_root = '/usr'

      include mysql::ruby
      include ruby::gems

      case $passengerversion {
        '2.2.11debian-2': {
          package { 'libapache2-mod-passenger':
            ensure  => '2.2.11debian-2',
            require => Package['apache2'],
            notify  => Service['apache2']
          }
        }
        '3.0.11+96~natty1': {
          package { 'libapache2-mod-passenger':
            ensure  => '3.0.11+96~natty1',
            require => Package['apache2'],
            notify  => Service['apache2']
          }
          package { 'passenger-common':
            ensure  => '3.0.11+96~natty1',
            require => Package['apache2'],
            notify  => Service['apache2']
          }
        }
      }

    } '1.9.3': {
      include ruby::rbenv

      # use rbenv ruby shim instead?
      $passenger_ruby = '/opt/rbenv/versions/1.9.3-p125/bin/ruby'
      $passenger_root = '/opt/rbenv/versions/1.9.3-p125/lib/ruby/gems/1.9.1/gems/passenger-3.0.11'

      file { '/etc/apache2/mods-available/passenger.load':
        ensure  => file,
        source  => 'puppet:///modules/apache2/ruby/passenger.load',
        require => [ Package['apache2'],
                     Class['ruby::rbenv'], ],
        notify  => Service['apache2'],
      }
    }

  }

  file { '/etc/apache2/mods-available/passenger.conf':
    ensure  => file,
    content => template('apache2/passenger.conf.erb'),
    require => Package['apache2'],
    notify  => Service['apache2'],
  }

}
