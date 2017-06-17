require 'spec_helper'

describe 'sssd' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "sssd::join::password class" do
          let(:params) do
            {
              :domain_join_user     => 'user',
              :domain_join_password => 'password',
              :domain               => 'example.com',
            }
          end

          it { is_expected.to contain_class('sssd::join::password') }

          it do
            is_expected.to contain_exec('adcli_join_with_password').with({
              'path'    => '/usr/bin:/usr/sbin:/bin',
              'command' => 'echo \'password\' | adcli join --stdin-password example.com --login-user=user',
              'unless'  => "klist -k /etc/krb5.keytab | grep -i 'foo@example.com'",
            })
          end
        end
      end
    end
  end
end
