class apache2::mods::standard {

    apache2::mods::disable { 'autoindex': }
    apache2::mods::enable { 'auth_basic': }
    apache2::mods::enable { 'expires': }
    apache2::mods::enable { 'deflate': }
    apache2::mods::enable { 'actions': }
    apache2::mods::enable { 'rewrite': }

}
