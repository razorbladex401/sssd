# sssd Puppet Module

[![Build Status](https://travis-ci.org/walkamongus/sssd.svg)](https://travis-ci.org/walkamongus/sssd)

####Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with sssd](#setup)
    * [What sssd affects](#what-sssd-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with sssd](#beginning-with-sssd)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)

##Overview

This module installs (if necessary) and configures the System Security Services Daemon. 
It will also join an AD domain with adcli and configure kerberos. 

##Module Description

The System Security Services Daemon bridges the gap between local authentication requests 
and remote authentication providers.  This module installs the required sssd packages and 
builds the sssd.conf configuration file. It will also enable the sssd service and ensure 
it is running.  It will also install the correct kerberos package (krb5-workstation or
krb5-user), configure the kerberos configuration file, and run adcli to join the domain.

Auto-creation of user home directories on first login via the PAM mkhomedir.so module may 
be enabled or disabled (defaults to disabled).

For SSH and Sudo integration with SSSD, this module works well with [saz/ssh](https://forge.puppetlabs.com/saz/ssh) and [trlinkin/nsswitch](https://forge.puppetlabs.com/trlinkin/nsswitch).

##Setup

###What sssd affects

* Packages
    * sssd
    * authconfig
    * oddjob-mkhomedir
    * libpam-runtime
    * libpam-sss
    * libnss-sss
    * sssd-ad
* Files
    * sssd.conf
* Services
    * sssd daemon
    * oddjobd
    * messagebus
* Execs
    * the authconfig or pam-auth-update commands are run to enable/disable SSSD functionality.
    * adcli join based on either a kerberos keytab or usernaname and password

###Beginning with sssd

Install SSSD with a bare default config file:

     class {'::sssd': }

##Usage

Install SSSD with custom configuration:

    class {'::sssd':
      config => {
        'sssd' => {
          'key'     => 'value',
          'domains' => ['MY_DOMAIN', 'LDAP',],
        },
        'domain/MY_DOMAIN' => {
          'key' => 'value',
        },
        'pam' => {
          'key' => 'value',
        },
      }
    }


##Reference

###Parameters

* `sssd_package_name`: String. Name of the SSSD package to install.
* `sssd_package_ensure`: String. Ensure value to set for the SSSD package.
* `sssd_service_name`: String. Name of the SSSD service to manage.
* `sssd_service_ensure`:  Variant[Enum['running','stopped'], Boolean]. Ensure value to set for the SSSD service.
* `sssd_config_file`: Stdlib::Absolutepath. Path to the `SSSD` config file.
* `sssd_config`: Hash. A hash of configuration options structured like the sssd.conf file. Array values will be joined into comma-separated lists. 
* `mkhomedir`: Boolean. Enables auto-creation of home directories on user login.
* `pam_mkhomedir_method`: Enum['pam-auth-update', 'authconfig']. Set supported method for controlling SSSD configuration.
* `pam_mkhomedir_file_path`: Variant[Stdlib::Absolutepath, Undef]. Path to the PAM mkhomedir config file. Only used when `pam_mkhomedir_method => pam-auth-update`.
* `cache_path`: Stdlib::Absolutepath. Path to the SSSD cache files.
* `clear_cache`: Boolean. Enables clearing of the SSSD cache on configuration updates.
* `required_packages`: Hash. A Hash of package resources to additionally install with the core SSSD packages
* `required_services`: Array. An array of services that need to be started.
* `adcli_package_name`: String.  Name of adcli package, defaults to adcli.
* `krb_client_package_name`: String.  Name of kerberos package, defaults to krb5-workstation on Redhat.
* `mkhomedir_package_names`: Array.  Names of packages required to enable homedirectory creation.
* `domain`: String.  Name of AD Domain to join.
* `domain_join_user`: String. Name of user to use to join the domain.
* `domain_join_password`: String.  Name of password for the `domain_join_user`.  Only needed if `krb_ticket_join` is false.
* `krb_keytab`: Stdlib::Absolutepath.  Path to keytab file with permission to join the domain.  Only needed if `krb_ticket_join` is true.
* `krb_config_file`:Stdlib::Absolutepath.  Path to kerberos configuration file.
* `krb_config`: Hash.   A hash of configuration options structured like the Kerberos configuration file. 
* `manage_krb_config`: Boolean. Whether or not to manage the kerberos configuration.
* `manage_oddjobd`: Boolean. Whether or not to manage the oddjobd service.
* `oddjobd_service_ensure`: Variant[Enum['running','stopped'], Boolean]. Ensure value to set for the oddjobd service, if manage_oddjobd is true.

For example:

    class {'::sssd':
      config => {
        'sssd' => {
          'key1' => 'value1',
          'keyX' => [ 'valueY', 'valueZ' ],
        },
        'domain/LDAP' => {
          'key2' => 'value2',
        },
      }

or in hiera:

    sssd::config:
      'sssd':
        key1: value1
        keyX:
          - valueY
          - valueZ
      'domain/LDAP':
        key2: value2

Will be represented in sssd.conf like this:

    [sssd]
    key1 = value1
    keyX = valueY, valueZ

    [domain/LDAP]
    key2 = value2

###Classes

* sssd::init
* sssd::install
* sssd::config
* sssd::join
* sssd::join::keytab
* sssd::join::password
* sssd::service

