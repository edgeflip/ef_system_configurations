class ruby::gems {

  file { '/etc/gemrc':
    ensure  => present,
    source  => 'puppet:///modules/ruby/gemrc',
  }

  package { 'rubygems':
    ensure   => 'latest',
    provider => apt,
    require  => [ File['/etc/gemrc'],
                  Class['apt::update'], ]
  }

  package { 'bundler':
    ensure   => present,
    provider => gem,
    require  => [ File['/etc/gemrc'],
                  Package['rubygems'] ],
  }

}
