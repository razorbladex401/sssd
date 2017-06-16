# == Class sssd::join::password
#
# This class is called from sssd for
# joining AD using a username and password.
#
class sssd::join::password {

  $_domain    = $::sssd::domain
  $_user      = $::sssd::domain_join_user
  $_password  = $::sssd::domain_join_password

  exec { 'adcli_join_with_password':
    path    => '/usr/bin:/usr/sbin:/bin',
    command => "echo '${_password}' | adcli join --stdin-password ${_domain} --login-user=${_user}",
    unless  => "klist -k /etc/krb5.keytab | grep -i '${::hostname[0,15]}@${_domain}'",
  }

}

