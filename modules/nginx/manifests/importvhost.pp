define nginx::importvhost ( $content ) {
  include nginx

  file { "/etc/nginx/sites-available/$name":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => 0644,
    content => $content,
    require => Package['nginx'],
    notify  => Service['nginx'],
  }

  file { "/etc/nginx/sites-enabled/$name":
    ensure  => link,
    target  => "/etc/nginx/sites-available/$name",
    require => File["/etc/nginx/sites-available/$name"],
    notify  => Service['nginx'],
  }

}
