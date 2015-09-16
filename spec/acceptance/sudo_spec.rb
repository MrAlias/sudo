require 'spec_helper_acceptance'

pp = <<-EOS
group { 'admin':
  ensure => present,
}

user { 'jim':
  ensure => present
}

user { 'jack':
  ensure  => present,
  gid     => 'admin',
  require => Group['admin'],
}

file { '/my_policies':
  ensure => directory,
}

file { '/policy2':
  ensure  => file,
  mode    => '0440',
  content => '%admin	ALL = (ALL:ALL) NOPASSWD: ALL',
}

file { '/policy1':
  ensure  => file,
  mode    => '0440',
  content => '%sudo	ALL = (ALL:ALL) ALL',
}

class { 'sudo':
  include_dir          => '/my_policies',
  include              => ['/policy1', '/policy2'],
  defaults_content     => 'Defaults	env_reset, mail_badpass, noexec',
  host_aliases_content => 'Host_Alias	SANS = backup1, backup2',
  user_aliases_content => 'User_Alias	PEONS = jim, joe, jack',
  cmnd_aliases_content => 'Cmnd_Alias	BACKUP = /bin/tar, /bin/cpio, /bin/mount',
  runas_spec_content   => 'PEONS	SANS = (admin) EXEC: BACKUP\nPEONS	ALL = (admin) BACKUP',
  require              => [
    File['/my_policies', '/policy1', '/policy2'],
    User['jim', 'jack'],
  ],
}
EOS

describe 'sudo' do
  describe 'running puppet code' do
    it 'should run without errors' do
      apply_manifest(pp, :catch_failures => true)
    end

    it 'should be idempotent' do
      apply_manifest(pp, :catch_changes => true)
    end

    it 'should create the correct policy for user jim' do
      list_sudo('jim') do |r|
        expect(r.stdout).to match(/^.*\n *env_reset, mail_badpass, noexec\n\n.*\n *\(admin\) \/bin\/tar, \/bin\/cpio, \/bin\/mount\n/)
      end
    end

    it 'should create the correct policy for user jack' do
      list_sudo('jack') do |r|
        expect(r.stdout).to match(/^.*\n *env_reset, mail_badpass, noexec\n\n.*\n *\(admin\) \/bin\/tar, \/bin\/cpio, \/bin\/mount\n *\(ALL : ALL\) NOPASSWD: ALL\n/)
      end
    end
  end
end
