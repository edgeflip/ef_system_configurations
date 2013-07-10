class base ( $production = true, $env = 'production' ) {
    if $production {
      include env::production
      #TODO: Setup shipem
      class { 'rsyslog::shipem': syslog_port => '514' }
    } else {
        $staging = true
    }

    include runstages
    include users
    include ntp
    #TODO: Add monitoring
    #include newrelic::server-agent
    #include opsview::agent

    class { 'creds': stage => prep }
    class { 'locale': stage => prep }
    class { 'apt': stage => prep, staging => $staging }
    class { 'apt::update': stage => prep }
    class { 'roles::efbase': stage => prep }
    class { 'users::keys': stage => prep,
                         require => Class['creds'], }
    class { 'puppet::client': }

    if $env != 'dev' {
      if !$production {
        # for testing in staging only
        include env::staging
        class { 'rsyslog::shipem': syslog_port => '514' }

      }
    }

    if $env == 'dev' {
      include env::dev
      include roles::dev
      class { 'creds::wipe': stage => post }
    }
}

# INHERITANCE AND BASE CLASSES
node apache_php  {
    class { 'apache2': mpm => 'prefork' }
    include apache2::php
}

node apache {
    include apache2
    apache2::mods::disable { 'status': }
}

node nodejs {
    include nodejs
}

node nginx_python {
    include nginx
    include uwsgi
}

node apache_modwsgi {
    include apache2
    include apache2::mod_wsgi
    include apache2::mods::standard
    apache2::mods::disable { 'ssl': }
}

node /^base-ddreigjjkeewe.*$/ {
    $production = false
    class { 'base': production => $production }
}

node /^apachebase-fdfhjjsqqerfds.*$/ inherits apache {
    $production = false
    $env = 'staging'
    class { 'base': production => $production }
}

# OPS AND DEPLOY NODES
node /^geppetto-eerrillhnbcdd.*$/ {
    $production = true
    $env = 'production'
    class { 'base': production => $production }
    include puppet::server
    apache2::mods::enable { 'ssl': }
}

node /^logger-efjbwaaawtgtyrtd.*$/ {
    $production = true
    $env = 'production'
    class { 'base': production => $production }
    class { 'roles::logger': }
}

# APP NODES
node /^eflip-staging-fjierwse.*$/ inherits apache_modwsgi {
    $production = false
    $env = 'staging'
    class { 'base': production => $production }
    class { 'apps::edgeflip': env => $env }
    class { 'creds::app': env => $env, app => "edgeflip",
                        stage => prep }
}

node /^demandaction-fjierwse.*$/ inherits apache_modwsgi {
    $production = true
    $env = 'production'
    class { 'base': production => $production }
    class { 'apps::edgeflip': env => $env, client => 'demandaction' }
    class { 'creds::app': env => $env, app => "edgeflip",
                        stage => prep }
}

node /^eflipcel-staging-frwse.*$/ inherits apache_modwsgi {
    $production = false
    $env = 'staging'
    class { 'base': production => $production }
    class { 'apps::edgeflipcelery': env => $env, nodetype => "web" }
    class { 'creds::app': env => $env, app => "edgeflip",
                        stage => prep }
}

node /^eflipcel-staging-celery.*$/ inherits apache_modwsgi {
    $production = false
    $env = 'staging'
    class { 'base': production => $production }
    class { 'apps::edgeflipcelery': env => $env, nodetype => "celery" }
    class { 'creds::app': env => $env, app => "edgeflip",
                        stage => prep }
}

node /^eflipcel-staging-rmq.*$/ inherits apache_modwsgi {
    $production = false
    $env = 'staging'
    class { 'base': production => $production }
    class { 'rabbitmq': newuser => "edgeflip", newpass => "edgeflip",
                        newvhost => "edgehost" }
    class { 'apps::edgeflipcelery': env => $env, nodetype => "rabbitmq" }
    class { 'creds::app': env => $env, app => "edgeflip",
                        stage => prep }
}
<<<<<<< HEAD
=======

node /^eflip-production-frwse.*$/ inherits apache_modwsgi {
    $production = true
    $env = 'production'
    class { 'base': production => $production }
    class { 'apps::edgeflipcelery': env => $env, nodetype => "web" }
    class { 'creds::app': env => $env, app => "edgeflip",
                        stage => prep }
}

node /^eflip-production-celery.*$/ inherits apache_modwsgi {
    $production = true
    $env = 'production'
    class { 'base': production => $production }
    class { 'apps::edgeflipcelery': env => $env, nodetype => "celery" }
    class { 'creds::app': env => $env, app => "edgeflip",
                        stage => prep }
}

node /^eflip-production-rmq.*$/ inherits apache_modwsgi {
    $production = true
    $env = 'production'
    class { 'base': production => $production }
    class { 'rabbitmq': newuser => "edgeflip", newpass => "edgeflip",
                        newvhost => "edgehost" }
    class { 'apps::edgeflipcelery': env => $env, nodetype => "rabbitmq" }
    class { 'creds::app': env => $env, app => "edgeflip",
                        stage => prep }
}
>>>>>>> morecelery
