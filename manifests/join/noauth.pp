# == Class sssd::join::noauth
#
# This class is called from sssd for performing
# an adjoin with no authentication offered.  
# Useful for pre-joined dmz servers.
#
class sssd::join::noauth {

  $_domain            = $::sssd::domain
  $_upcase_domain     = upcase($::sssd::domain)
  $_domain_join_user  = $::sssd::domain_join_user
  $_domain_controller = $::sssd::domain_controller
  $_domain_test_user  = $sssd::domain_test_user
  $_extra_args        = $sssd::extra_args



  if $_domain_controller {
    $_server_opt = "-S ${_domain_controller}"
  } else {
    $_server_opt = '' 
  }

  $_opts = [
    '-v',
    '--show-details',
    $_server_opt,
  ]

  $_join_opts = delete(concat($_opts, $_extra_args), '')
  $_options   = join($_join_opts, ' ')


  if $_domain_test_user {
    exec { 'adcli_join_with_noauth':
      path    => '/usr/bin:/usr/sbin:/bin',
      command => "adcli join ${_options} ${_upcase_domain} | tee /tmp/adcli-join-${_upcase_domain}.log",
      unless  => "id ${_domain_test_user} > /dev/null 2>&1",
    }
  } else {
    exec { 'adcli_join_with_noauth':
      path    => '/usr/bin:/usr/sbin:/bin',
      command => "adcli join ${_options} ${_upcase_domain} | tee /tmp/adcli-join-${_upcase_domain}.log",
      unless  => "klist -k /etc/krb5.keytab | grep -i '${::hostname[0,15]}@${_domain}'",
    }
  }
}
