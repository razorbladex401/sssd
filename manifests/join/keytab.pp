# == Class sssd::join::keytab
#
# This class is called from sssd for performing
# a passwordless AD join with a Kerberos keytab
#
class sssd::join::keytab {

  $_domain            = $::sssd::domain
  $_upcase_domain     = upcase($::sssd::domain)
  $_domain_join_user  = $::sssd::domain_join_user
  $_domain_controller = $::sssd::domain_controller
  $_krb_keytab        = $::sssd::krb_keytab
  $_domain_test_user  = $sssd::domain_test_user
  $_extra_args        = $sssd::extra_args

  $_server_opt = $_domain_controller ? {
    undef   => '',
    default => "-S ${_domain_controller}",
  }

  $_opts = [
    '--login-ccache',
    '-v',
    '--show-details',
    $_server_opt,
  ]

  $_join_opts = delete(concat($_opts, $_extra_args), '')
  $_options   = join($_join_opts, ' ')


  file { 'krb_keytab':
    path   => $_krb_keytab,
    owner  => 'root',
    group  => 'root',
    mode   => '0400',
    notify => Exec['run_kinit_with_keytab'],
  }

  exec { 'run_kinit_with_keytab':
    path      => '/usr/bin:/usr/sbin:/bin',
    command   => "kinit -kt ${_krb_keytab} ${_domain_join_user}",
    logoutput => true,
    unless    => "klist -k | grep $(kvno `hostname -s` | awk '{print \$4}')",
    before    => Exec['adcli_join_with_keytab'],
  }

  exec { 'adcli_join_with_keytab':
    path      => '/usr/bin:/usr/sbin:/bin',
    command   => "adcli join ${_options} ${_upcase_domain}",
    logoutput => true,
    tries     => '3',
    try_sleep => '10',
    unless    => "klist -k | grep $(kvno `hostname -s` | awk '{print \$4}')",
    require   => Exec['run_kinit_with_keytab'],
  }
}

