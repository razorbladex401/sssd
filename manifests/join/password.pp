# == Class sssd::join::password
#
# This class is called from sssd for
# joining AD using a username and password.
#
class sssd::join::password {

  $_domain            = $::sssd::domain
  $_upcase_domain     = upcase($::sssd::domain)
  $_user              = $::sssd::domain_join_user
  $_password          = $::sssd::domain_join_password
  $_domain_controller = $sssd::domain_controller
  $_extra_args        = $sssd::extra_args

  $_server_opt = $_domain_controller ? {
    undef   => '',
    default => "-S ${_domain_controller}",
  }

  $_opts = [
    '--stdin-password',
    '-v',
    '--show-details',
    "--login-user ${_user}",
    $_server_opt,
  ]

  $_join_opts = delete(concat($_opts, $_extra_args), '')
  $_options   = join($_join_opts, ' ')


  exec { 'adcli_join_with_password':
    path      => '/usr/bin:/usr/sbin:/bin',
    command   => "echo '${_password}' | adcli join ${_options} ${_upcase_domain}",
    logoutput => true,
    tries     => '3',
    try_sleep => '10',
    unless    => "klist -k | grep $(kvno `hostname -s` | awk '{print \$4}')",
  }
}

