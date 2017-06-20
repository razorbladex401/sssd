require 'spec_helper'

describe 'sssd' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "sssd::join::keytab class with default krb_config" do
          let(:params) do
            {
              :krb_ticket_join       => true,
              :domain_join_user      => 'user',
              :krb_keytab            => '/tmp/join.keytab',
              :krb_config_file       => '/etc/krb5.conf',
              :domain                => 'example.com',
              :manage_krb_config     => true,
            }
          end

          it { is_expected.to contain_class('sssd::join::keytab') }

          it do
            is_expected.to contain_file('krb_keytab').with({
              'path'  => '/tmp/join.keytab',
              'owner' => 'root',
              'group' => 'root',
              'mode'  => '0400',
            }).that_notifies('Exec[run_kinit_with_keytab]')
          end

          it do
            is_expected.to contain_file('krb_configuration').with({
              'path'  => '/etc/krb5.conf',
              'owner' => 'root',
              'group' => 'root',
              'mode'  => '0644',
            }).that_notifies('Exec[run_kinit_with_keytab]')
          end

          it do
            is_expected.to contain_exec('run_kinit_with_keytab').with({
              'path'        => '/usr/bin:/usr/sbin:/bin',
              'command'     => 'kinit -kt /tmp/join.keytab user',
              'refreshonly' => 'true',
            }).that_comes_before('Exec[adcli_join_with_keytab]')
          end

          it do
            is_expected.to contain_exec('adcli_join_with_keytab').with({
              'path'    => '/usr/bin:/usr/sbin:/bin',
              'command' => 'adcli join --login-ccache -v EXAMPLE.COM | tee /tmp/adcli-join-EXAMPLE.COM.log',
              'unless'  => "klist -k /etc/krb5.keytab | grep -i 'foo@example.com'",
            })
          end
        end

        context "sssd::join::keytab class with default krb_config and a domain test user" do
          let(:params) do
            {
              :krb_ticket_join       => true,
              :domain_join_user      => 'user',
              :krb_keytab            => '/tmp/join.keytab',
              :krb_config_file       => '/etc/krb5.conf',
              :domain                => 'example.com',
              :manage_krb_config     => true,
              :domain_test_user      => 'known_user',
            }
          end
          it do
            is_expected.to contain_exec('adcli_join_with_keytab').with({
              'path'    => '/usr/bin:/usr/sbin:/bin',
              'command' => 'adcli join --login-ccache -v EXAMPLE.COM | tee /tmp/adcli-join-EXAMPLE.COM.log',
              'unless'  => "id known_user > /dev/null 2>&1",
            })
          end
        end

        context "sssd::join::keytab class with custom krb_config" do
          let(:params) do
            {
              :krb_ticket_join   => true,
              :domain_join_user  => 'user',
              :krb_keytab        => '/tmp/join.keytab',
              :krb_config_file   => '/etc/krb5.conf',
              :domain            => 'example.com',
              :manage_krb_config => true,
              :krb_config        => {
                'libdefaults' => {
                  'default_realm' => 'EXAMPLE.COM',
                },
                'domain_realm' => {
                  'localhost.example.com' => 'EXAMPLE.COM',
                },
                'realms' => {
                  'EXAMPLE.COM' => {
                    'kdc' => 'dc.example.com:88',
                  },
                },
              }
            }
          end

          it { is_expected.to contain_class('sssd::join::keytab') }

          it do
            should contain_file('krb_configuration').with_content(
              /\[domain_realm\]\nlocalhost.example.com = EXAMPLE.COM\n/
            )
          end

          it do
            should contain_file('krb_configuration').with_content(
              /\[libdefaults\]\ndefault_realm = EXAMPLE.COM\n/
            )
          end

          it do
            should contain_file('krb_configuration').with_content(
              /\[realms\]\nEXAMPLE.COM = {\n  kdc = dc.example.com:88\n/
            )
          end
        end
      end
    end
  end
end
