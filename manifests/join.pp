# == Class sssd::join
#
# This class is called from realmd for joining AD.
#
class sssd::join {

  case $::sssd::join_type {
    /^keytab$/: {
      contain '::sssd::join::keytab'
    } 
    /^password$/: {
      contain '::sssd::join::password'
    }
    /^noauth$/: {
    contain '::sssd::join::noauth'
    }
    /^none$/: {
    }
    default: {
      fail("Invalid join_type: ${::sssd::join_type}.")
    }
  }
}

