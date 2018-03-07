require 'spec_helper'

describe 'sssd' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "sssd::join::password class with minimum arguments" do
          let(:params) do
            {
              :domain    => 'example.com',
              :join_type => 'noauth',
            }
          end

          it { is_expected.to contain_class('sssd::join::noauth') }

          it do
            is_expected.to contain_exec('adcli_join_with_noauth').with({
              'path'    => '/usr/bin:/usr/sbin:/bin',
              'command' => 'adcli join -v --show-details EXAMPLE.COM',
              'logoutput' => 'true',
              'tries'     => '3',
              'try_sleep' => '10',
              'unless'    => "klist -k | grep $(kvno `hostname -s` | awk '{print $4}')",
            })
          end
        end
        context "sssd::join::password class specifying a test user and domain controller" do
          let(:params) do
            {
              :domain            => 'example.com',
              :domain_controller => 'dc01.example.com',
              :domain_test_user  => 'knownuser',
              :join_type         => 'noauth',
            }
          end

          it { is_expected.to contain_class('sssd::join::noauth') }

          it do
            is_expected.to contain_exec('adcli_join_with_noauth').with({
              'path'    => '/usr/bin:/usr/sbin:/bin',
              'command' => 'adcli join -v --show-details -S dc01.example.com EXAMPLE.COM',
              'logoutput' => 'true',
              'tries'     => '3',
              'try_sleep' => '10',
              'unless'    => "klist -k | grep $(kvno `hostname -s` | awk '{print $4}')",
            })
          end
        end
      end
    end
  end
end
