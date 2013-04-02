class nodejs {

  package { 'nodejs':
    ensure => latest,
  }

  package { 'nodejs-dbg':
    ensure => latest,
  }

  package { 'nodejs-dev':
    ensure => latest,
  }

}
