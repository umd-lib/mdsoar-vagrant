class { 'postgresql::globals':
    manage_package_repo => true,
    version             => '9.4',
}->
class { 'postgresql::server': }

# PostgreSQL setup based on DSpace documentation
# https://wiki.duraspace.org/display/DSDOC5x/Installing+DSpace
postgresql::server::db { 'dspace':
    user     => 'dspace',
    owner     => 'dspace',
    password => postgresql_password('dspace', 'dspace'),
    encoding => 'UNICODE',
}
postgresql::server::pg_hba_rule { 'dspace access':
    type        => 'host',
    database    => 'dspace',
    user        => 'dspace',
    address     => '127.0.0.1/32',
    auth_method => 'md5',
    order       => '001',
}
# ensure there is a "root" superuser, for compatability with production db dumps
postgresql::server::role { 'root':
    superuser => true,
}

# required packages to generate thumbnails (LIBCIR-71)
package { "ghostscript":
    ensure => present,
}
package { "ImageMagick":
    ensure => present,
}

file { "/apps/mdsoar":
    ensure => 'directory',
    owner  => 'vagrant',
    group  => 'vagrant',
}

# Tomcat logs directory
file { "/apps/mdsoar/tomcat/logs":
    ensure => 'directory',
    owner  => 'vagrant',
    group  => 'vagrant',
}

# by default the CentOS 6.6 iptables config has
# all ports closed except for SSH (22)
firewall { '100 allow http and https access':
    dport   => [80, 443, 8080, 8443, 8983],
    proto  => tcp,
    action => accept,
}

# Install Git
include git

# Ensure that the correct branch of solr-env is checked out
vcsrepo { '/apps/solr-env-sync':
  ensure   => present,
  provider => git,
  revision => 'local',
}