# == Class sssd::service
#
# This class is meant to be called from sssd
# It ensure the service is running
#
class sssd::service {

  if $sssd::manage_oddjobd == true {
    $before = 'Service[oddjobd]'
    ensure_resource('service', 'oddjobd',
      {
        ensure     => $sssd::oddjobd_service_ensure,
        enable     => true,
        hasstatus  => true,
        hasrestart => true,
      }
    )
  } else {
    $before = undef
  }

  ensure_resource('service', $sssd::sssd_service_name,
    {
      ensure     => $sssd::sssd_service_ensure,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
      before     => $before,
    }
  )
 
  if ! empty($sssd::required_services) {
    ensure_resource('service', $sssd::required_services,
      {
        ensure     => running,
        enable     => true,
        before     => $before,
      }
    )
  }

}
