require 'spec_helper'

describe 'sudo', :type => 'class' do
  context 'with defaults for all parameters' do
    it {
      should compile.with_all_deps
      should contain_class('sudo')
      should contain_package('sudo')
    }
  end

  context 'with custom correct parameters' do
    let(:params) do
      {
        :package_name         => 'test_sudo',
        :sudoers_file         => '/root/sudoers',
        :include_dirs         => ['/root/sudoers.d'],
        :defaults_content     => 'test default content',
        :host_aliases_content => 'test host_aliases content',
        :user_aliases_content => 'test user_aliases content',
        :cmnd_aliases_content => 'test cmnd_aliases content',
        :runas_spec_content   => 'test runas_spec content',
        :update_rkhunter      => true
      }
    end

    it {
      should compile.with_all_deps
      should contain_class('sudo')
      should contain_package('sudo').with({:name => 'test_sudo'})
      should contain_concat('/root/sudoers').with(
        {
          :ensure => 'present',
          :owner  => 'root',
          :group  => 'root',
          :mode   => '0440',
          :warn   => true,
        }
      ).that_requires('Package[sudo]')
      should contain_concat__fragment('Defaults').with(
        {
          :ensure  => 'present',
          :target  => '/root/sudoers',
          :content => 'test default content',
          :order   => '01',
        }
      )
      should contain_concat__fragment('Host Aliases').with(
        {
          :ensure  => 'present',
          :target  => '/root/sudoers',
          :content => 'test host_aliases content',
          :order   => '02',
        }
      )
      should contain_concat__fragment('User Aliases').with(
        {
          :ensure  => 'present',
          :target  => '/root/sudoers',
          :content => 'test user_aliases content',
          :order   => '03',
        }
      )
      should contain_concat__fragment('Cmnd Aliases').with(
        {
          :ensure  => 'present',
          :target  => '/root/sudoers',
          :content => 'test cmnd_aliases content',
          :order   => '04',
        }
      )
      should contain_concat__fragment('Runas Spec').with(
        {
          :ensure  => 'present',
          :target  => '/root/sudoers',
          :content => 'test runas_spec content',
          :order   => '05',
        }
      )
      should contain_concat__fragment('includedirs').with(
        {
          :ensure  => 'present',
          :target  => '/root/sudoers',
          :content => "# See sudoers(5) for more information on \"#include\" directives:\n\n#includedir /root/sudoers.d\n\n",
          :order   => '06',
        }
      )
      should contain_exec('Syntax check for /root/sudoers').with(
        {
          :command     => "visudo -c -f /root/sudoers || ( rm -f '/root/sudoers' && exit 1)",
          :refreshonly => true,
        }
      ).that_subscribes_to('Concat[/root/sudoers]')
      should contain_exec('rkhunter-propupd sudo').with(
        {
          :command     => '/usr/bin/rkhunter --propupd sudo',
          :refreshonly => true,
          :timeout     => 3600,
        }
      ).that_subscribes_to('Exec[Syntax check for /root/sudoers]')
    }
  end

  context 'with bad package_name type' do
    let(:params) do
      { :package_name => ['test_sudo'] }
    end

    it { should compile.and_raise_error(/\["test_sudo"\] is not a string/) }
  end

  context 'with bad sudoers_file absolute path' do
    let(:params) do
      { :sudoers_file => './root/sudoers' }
    end

    it { should compile.and_raise_error(/"\.\/root\/sudoers" is not an absolute path/) }
  end

  context 'with bad include_dirs type' do
    let(:params) do
      { :include_dirs => './root/sudoers.d' }
    end

    it { should compile.and_raise_error(/"\.\/root\/sudoers.d" is not an Array/) }
  end

  context 'with bad defaults_content type' do
    let(:params) do
      { :defaults_content => ['this', 'that'] }
    end

    it { should compile.and_raise_error(/\["this", "that"\] is not a string/) }
  end

  context 'with bad host_aliases_content type' do
    let(:params) do
      { :host_aliases_content => {} }
    end

    it { should compile.and_raise_error(/{} is not a string/) }
  end

  context 'with bad user_aliases_content type' do
    let(:params) do
      { :user_aliases_content => 1234 }
    end

    it { should compile.and_raise_error(/1234 is not a string/) }
  end

  context 'with bad cmnd_aliases_content type' do
    let(:params) do
      { :cmnd_aliases_content => false }
    end

    it { should compile.and_raise_error(/false is not a string/) }
  end

  context 'with bad runas_spec_content type' do
    let(:params) do
      { :runas_spec_content => ['test runas_spec content'] }
    end

    it { should compile.and_raise_error(/\["test runas_spec content"\] is not a string/) }
  end

  context 'with bad type' do
    let(:params) do
      { :update_rkhunter => 'yes' }
    end

    it { should compile.and_raise_error(/"yes" is not a boolean/) }
  end
end
