# == Class sssd::join
#
# This class is called from realmd for joining AD.
#
class sssd::join {

  if $::sssd::krb_ticket_join {
    contain '::sssd::join::keytab'
  }
  else {
    contain '::sssd::join::password'
  }

}

