# == Class sssd::service
#
# This class is meant to be called from sssd
# It ensure the service is running
#
class sssd::service {

  service { $sssd::sssd_service_name:
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
 
  if $::sssd::required_services {
    service  { $::sssd::required_services:
      ensure     => running,
      enable     => true,
    }
  }

}
