# == Class: sssd
#
# Full description of class sssd here.
#
# === Parameters
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#
class sssd (

  String $sssd_package_name,
  String $sssd_package_ensure,
  String $sssd_service_name,
  Variant[Enum['running','stopped'], Boolean] $sssd_service_ensure,
  Stdlib::Absolutepath $sssd_config_file,
  Hash $sssd_config,
  Boolean $mkhomedir,
  Enum['pam-auth-update', 'authconfig'] $pam_mkhomedir_method,
  Variant[Stdlib::Absolutepath, Undef] $pam_mkhomedir_file_path,
  Stdlib::Absolutepath $cache_path,
  Boolean $clear_cache,
  Hash $required_packages,
  Variant[Array, Undef] $required_services = undef,
  String $adcli_package_name,
  String $krb_client_package_name,
  Array $mkhomedir_package_names,
  String $domain,
  Variant[String, Undef] $domain_join_user = undef,
  Variant[String, Undef] $domain_join_password = undef,
  Boolean $krb_ticket_join,
  Variant[Stdlib::Absolutepath, Undef] $krb_keytab = undef,
  Stdlib::Absolutepath $krb_config_file,
  Hash $krb_config,
  Boolean $manage_krb_config,
  Boolean $manage_oddjobd,
  Variant[Enum['running','stopped'], Boolean] $oddjobd_service_ensure,

) {

  contain '::sssd::install'
  contain '::sssd::config'
  contain '::sssd::join'
  contain '::sssd::service'

  Class['::sssd::install']
  -> Class['::sssd::config']
  ~> Class['::sssd::join']
  ~> Class['::sssd::service']
}
