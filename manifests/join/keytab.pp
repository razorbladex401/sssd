# == Class sssd::join::keytab
#
# This class is called from sssd for performing
# a passwordless AD join with a Kerberos keytab
#
class sssd::join::keytab {

  $_domain            = $::sssd::domain
  $_domain_join_user  = $::sssd::domain_join_user
  $_krb_keytab        = $::sssd::krb_keytab
  $_krb_config_file   = $::sssd::krb_config_file
  $_krb_config        = $::sssd::krb_config
  $_manage_krb_config = $::sssd::manage_krb_config

  file { 'krb_keytab':
    path   => $_krb_keytab,
    owner  => 'root',
    group  => 'root',
    mode   => '0400',
    notify => Exec['run_kinit_with_keytab'],
  }

  if $_manage_krb_config {
    file { 'krb_configuration':
      ensure  => file,
      path    => $_krb_config_file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('sssd/krb5.conf.erb'),
      notify  => Exec['run_kinit_with_keytab'],
    }
  }

  exec { 'run_kinit_with_keytab':
    path        => '/usr/bin:/usr/sbin:/bin',
    command     => "kinit -kt ${_krb_keytab} ${_domain_join_user}",
    refreshonly => true,
    before      => Exec['adcli_join_with_keytab'],
  }

  exec { 'adcli_join_with_keytab':
    path    => '/usr/bin:/usr/sbin:/bin',
    command => "adcli join --login-ccache ${_domain}",
    unless  => "klist -k /etc/krb5.keytab | grep -i '${::hostname[0,15]}@${_domain}'",
    require => Exec['run_kinit_with_keytab'],
  }

}

