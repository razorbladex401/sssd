# == Class sssd::config
#
# This class is called from sssd
#
class sssd::config {

  $_manage_krb_config = $::sssd::manage_krb_config
  $_krb_config_file   = $::sssd::krb_config_file
  $_krb_config        = $::sssd::krb_config

  $cache_flush_test = "test $(find ${sssd::cache_path} -size +2999M | wc -l) -gt 0"

  if $sssd::clear_cache {
    $config_params = {
      'notify'  => 'Exec[clear_cache]',
    }
  } else {
    $config_params = {}
  }


  if $_manage_krb_config {
    file { 'krb_configuration':
      ensure  => file,
      path    => $_krb_config_file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('sssd/krb5.conf.erb'),
    }
  }

  file {'sssd_config_file':
    ensure  => file,
    path    => $sssd::sssd_config_file,
    content => template('sssd/sssd.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    *       => $config_params,
  }

  exec {'cache_overflow':
    path    => '/usr/bin:/usr/sbin:/bin',
    command => '/bin/true',
    onlyif  => $cache_flush_test,
    notify  => Exec['clear_cache'],
  }

  exec {'clear_cache':
    refreshonly => true,
    command     => "/bin/rm -f ${sssd::cache_path}",
    notify      => Service['sssd'],
  }

  if $sssd::mkhomedir {
    $pam_mkhomedir_file_ensure = file
    $authconfig_args = ['--enablemkhomedir', '--enablesssd', '--enablesssdauth']

  } else {
    $pam_mkhomedir_file_ensure = absent
    $authconfig_args = ['--disablemkhomedir', '--disablesssd', '--disablesssdauth']
  }

  case $sssd::pam_mkhomedir_method {
    'pam-auth-update': {
      file { $sssd::pam_mkhomedir_file_path:
        ensure => $pam_mkhomedir_file_ensure,
        source => 'puppet:///modules/sssd/mkhomedir',
        notify => Exec['update_mkhomedir'],
      }

      exec {'update_mkhomedir':
        command     => '/usr/sbin/pam-auth-update',
        refreshonly => true,
      }
    }
    'authconfig': {
      $args = join($authconfig_args, ' ')

      exec { 'authconfig_update':
        command => "authconfig ${args} --update",
        path    => ['/sbin', '/bin', '/usr/sbin', '/usr/bin'],
        unless  => "/usr/bin/test \"$(authconfig ${args} --test)\" = \"$(authconfig --test)\"",
      }
    }
    default: {}
  }

}
