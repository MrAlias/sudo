require 'beaker-rspec'

hosts.each do |host|
  install_package(host, 'locales')

  create_remote_file host, '/etc/locale.gen', 'en_US.UTF-8 UTF-8'
  shell 'locale-gen'
  host.add_env_var('LANG', 'en_US.UTF-8')
  host.add_env_var('LANGUAGE', 'en_US.UTF-8')
  host.add_env_var('LC_ALL', 'en_US.UTF-8')

  install_package(host, 'wget')
  install_package(host, 'rsync')

  on host, install_puppet
  on host, puppet('module install puppetlabs-stdlib -v 4.5.1')
  on host, puppet('module install puppetlabs-concat -v 1.2.0')
end

RSpec.configure do |c|
  module_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  module_name = module_root.split(File::SEPARATOR).last

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    puppet_module_install(:source => module_root, :module_name => module_name)
  end
end

# Return the allowed (and forbidden) commands for the given user
def list_sudo(user, acceptable_exit_codes = [0], &block)
  shell("sudo -l -U #{user}", :acceptable_exit_codes => acceptable_exit_codes, &block)
end
