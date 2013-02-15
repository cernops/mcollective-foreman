# This class configures a foreman discovery agent for mcollective

class mco_foreman {

  hiera("foreman_url", "http://foreman:443")

  file { '/usr/libexec/mcollective/mcollective/discovery/foreman.rb':
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => 0755,
    content => template('foreman.rb.erb')
  }
 
  file { '/usr/libexec/mcollective/mcollective/discovery/foreman.ddl':
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => 0755,
    content => template('foreman.ddl.erb')
  }                                  

}
