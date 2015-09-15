class { 'sudo':
  package_name         => 'sudo package name',
  sudoers_file         => '/test/etc/sudoers',
  include_dirs         => ['/test/etc/sudoers.d'],
  defaults_content     => 'test defaults content',
  host_aliases_content => 'test host_aliases content',
  user_aliases_content => 'test user_aliases content',
  cmnd_aliases_content => 'test cmnd_aliases content',
  runas_spec_content   => 'test runas_spec content',
}
