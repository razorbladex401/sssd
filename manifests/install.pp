# == Class sssd::install
#
class sssd::install {

  package { $sssd::sssd_package_name:
    ensure => $sssd::sssd_package_ensure,
  }

  $_package_list = [
    $::sssd::adcli_package_name,
    $::sssd::krb_client_package_name,
    $::sssd::mkhomedir_package_names,
  ]
  $_packages = flatten($_package_list)

  package { $_packages:
    ensure => present,
  }

  ensure_packages($sssd::required_packages)

}
