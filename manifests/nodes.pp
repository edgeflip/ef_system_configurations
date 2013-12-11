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

node /^eflip-sentry.*$/ {
    $production = true
    $env = 'production'
    class { 'base': production => $production }
    class { 'apps::sentry': }
}

# APP NODES
# STAGING
# Web
node /^edgeflip-staging-fjierwse.*$/ inherits apache_modwsgi {
    $production = false
    $env = 'staging'
    class { 'base': production => $production }
    class { 'apps::webflip': env => $env }
    class { 'creds::app': env => $env, app => "edgeflip",
                        stage => prep }
}

# Celery
node /^edgeflip-staging-celery-dfker.*$/ inherits apache_modwsgi {
    $production = false
    $env = 'staging'
    class { 'base': production => $production }
    class { 'apps::celeryflip': env => $env }
    class { 'creds::app': env => $env, app => "edgeflip",
                        stage => prep }
}

# FB Sync Celery
node /^edgeflip-staging-fbsync.*$/ inherits apache_modwsgi {
    $production = false
    $env = 'staging'
    class { 'base': production => $production }
    class { 'apps::celeryflip': env => $env, celerytype => "fbsync" }
    class { 'creds::app': env => $env, app => "edgeflip",
                        stage => prep }
}

# RabbitMQ
node /^edgeflip-staging-rmq-dfker.*$/ inherits apache_modwsgi {
    $production = false
    $env = 'staging'
    class { 'base': production => $production }
    class { 'apps::webflip': env => $env }
    class { 'creds::app': env => $env, app => "edgeflip",
                        stage => prep }
    class { 'rabbitmq': newuser => "edgeflip", newpass => "edgeflip",
                        newvhost => "edgehost" }
}

# PRODUCTION 
# Web
node /^eflip-production-frwse.*$/ inherits apache_modwsgi {
    $production = true
    $env = 'production'
    class { 'base': production => $production }
    class { 'apps::webflip': env => $env }
    class { 'creds::app': env => $env, app => "edgeflip",
                        stage => prep }
}

# Celery
node /^eflip-production-celery.*$/ inherits apache_modwsgi {
    $production = true
    $env = 'production'
    class { 'base': production => $production }
    class { 'apps::celeryflip': env => $env }
    class { 'creds::app': env => $env, app => "edgeflip",
                        stage => prep }
}

# FB Sync Celery
node /^eflip-production-fbsync.*$/ inherits apache_modwsgi {
    $production = true
    $env = 'production'
    class { 'base': production => $production }
    class { 'apps::celeryflip': env => $env, celerytype => "fbsync" }
    class { 'creds::app': env => $env, app => "edgeflip",
                        stage => prep }
}

# RabbitMQ
node /^eflip-production-rmq.*$/ inherits apache_modwsgi {
    $production = true
    $env = 'production'
    class { 'base': production => $production }
    class { 'rabbitmq': newuser => "edgeflip", newpass => "edgeflip",
                        newvhost => "edgehost" }
    class { 'apps::webflip': env => $env }
    class { 'creds::app': env => $env, app => "edgeflip",
                        stage => prep }
}

