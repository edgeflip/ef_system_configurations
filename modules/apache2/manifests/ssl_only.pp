# add a vhost file to redirect any non-https requests
class apache2::ssl_only ( $redirect_port='8080' ) {
#TODO need to enable mod_rewrite

  apache2::templatevhost { "0_ssl_only_redirect":
    content => template('apache2/ssl_redirect_vhost.erb'),
  }

}
