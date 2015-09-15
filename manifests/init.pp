# == Class: sudo
#
# Manages the Sudo package and authorization capabilities.
#
# === Parameters
#
# [*package_name*]
#   Name of sudo package to install.
#
# [*sudoers_file*]
#   Location where the main sudoers file is located.
#
# [*include*]
#   Array of files to include in policy.
#
# [*include_dir*]
#   Absolute path to directory for system package policies.
#
#   This ensures the directory is specifies in the main policy to be
#   included as the place where the system package manager can drop sudoers
#   rules into as part of the package installation.
#
# [*defaults_content*]
#   The content of the main sudoers file that sets the sudo defaults.
#
# [*host_aliases_content*]
#   The content of the main sudoers file that sets the sudo host_aliases.
#
# [*user_aliases_content*]
#   The content of the main sudoers file that sets the sudo user_aliases.
#
# [*cmnd_aliases_content*]
#   The content of the main sudoers file that sets the sudo cmnd_aliases.
#
# [*runas_spec_content*]
#   The content of the main sudoers file that sets the main sudo runas_spec.
#
# [*update_rkhunter*]
#   Specify if rkhunter should be updated after any change is made.
#
#   Any changes to the sudoers policy will cause rkhunter to error.  This
#   provides a convenient way to automatically update rkhunter of changes
#   to the sudoers policy.
#
# === Examples
#
#  class { 'sudo':
#    sudoers_file         => '/root/sudoers',
#    include              => ['/home/me/my.policy]',
#    include_dir          => '/root/sudoers.d',
#    defaults_content     => "Defaults	env_reset",
#    runas_spec_content   => "root	ALL=(ALL:ALL) ALL",
#  }
#
# === Authors
#
# Tyler Yahn <codingalias@gmail.com>
#
class sudo (
  $package_name         = hiera("${module_name}::package_name", 'sudo'),
  $sudoers_file         = hiera("${module_name}::sudoers_file", '/etc/sudoers'),
  $include              = hiera_array("${module_name}::include_dirs", []),
  $include_dir          = hiera("${module_name}::include_dir", '/etc/sudoers.d'),
  $defaults_content     = hiera("${module_name}::defaults_content", template("${module_name}/defaults.erb")),
  $host_aliases_content = hiera("${module_name}::host_aliases_content", template("${module_name}/host_aliases.erb")),
  $user_aliases_content = hiera("${module_name}::user_aliases_content", template("${module_name}/user_aliases.erb")),
  $cmnd_aliases_content = hiera("${module_name}::cmnd_aliases_content", template("${module_name}/cmnd_aliases.erb")),
  $runas_spec_content   = hiera("${module_name}::runas_spec_content", template("${module_name}/runas_spec.erb")),
  $update_rkhunter      = hiera("${module_name}::update_rkhunter", false),
) {
  validate_absolute_path($sudoers_file)
  validate_absolute_path($include_dir)

  validate_array($include)

  validate_string(
    $package_name,
    $defaults_content,
    $host_aliases_content,
    $user_aliases_content,
    $cmnd_aliases_content,
    $runas_spec_content,
  )

  validate_bool($update_rkhunter)

  ensure_packages('sudo', {'name' => $package_name})

  # Construct the main sudoers file in parts.
  concat { $sudoers_file:
    ensure         => present,
    owner          => 'root',
    group          => 'root',
    mode           => '0440',
    warn           => true,
    ensure_newline => true,
    require        => Package['sudo'],
  }

  Concat::Fragment {
    ensure => present,
    target => $sudoers_file,
  }

  concat::fragment { 'Defaults':
    content => $defaults_content,
    order   => '01',
  }

  concat::fragment { 'Host Aliases':
    content => $host_aliases_content,
    order   => '02',
  }

  concat::fragment { 'User Aliases':
    content => $user_aliases_content,
    order   => '03',
  }

  concat::fragment { 'Cmnd Aliases':
    content => $cmnd_aliases_content,
    order   => '04',
  }

  concat::fragment { 'Runas Spec':
    content => $runas_spec_content,
    order   => '05',
  }

  concat::fragment { 'includes':
    content => template("${module_name}/includes.erb"),
    order   => '06',
  }

  # Don't install a bad sudoers policy
  exec { "Syntax check for ${sudoers_file}":
    command     => "visudo -c -f ${sudoers_file} || ( rm -f '${sudoers_file}' && exit 1)",
    refreshonly => true,
    subscribe   => Concat[$sudoers_file],
    path        => [
      '/bin',
      '/sbin',
      '/usr/bin',
      '/usr/sbin',
      '/usr/local/bin',
      '/usr/local/sbin'
    ],
  }

  if $update_rkhunter {
    exec { 'rkhunter-propupd sudo':
      command     => '/usr/bin/rkhunter --propupd sudo',
      refreshonly => true,
      timeout     => 3600,
      subscribe   => Exec["Syntax check for ${sudoers_file}"]
    }
  }
}
