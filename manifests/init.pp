# == Class: sudo
#
# Manages the Sudo package an authorization capabilities.
#
# === Parameters
#
# [*package_name*]
#   Name of sudo package.
#
# [*service_name*]
#   Name of the sudo service the module will manage.
#
# [*sudoers_file*]
#   Location where the main sudoers file is located.
#
# [*include_dirs*]
#   Array of all directories to include in the main sudoers file.  All
#   additional files found in these directories are treated as sudo config
#   files.
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
# === Examples
#
#  class { 'sudo': }
#
# === Authors
#
# Tyler Yahn <codingalias@gmail.com>
#
class sudo (
  $package_name         = hiera("${module_name}::package_name", 'sudo'),
  $service_name         = hiera("${module_name}::service_name", 'sudo'),
  $sudoers_file         = hiera("${module_name}::sudoers_file", '/etc/sudoers'),
  $include_dirs         = hiera_array("${module_name}::include_dirs", ['/etc/sudoers.d']),
  $defaults_content     = hiera("${module_name}::defaults_content", template("${module_name}/defaults.erb")),
  $host_aliases_content = hiera("${module_name}::host_aliases_content", template("${module_name}/host_aliases.erb")),
  $user_aliases_content = hiera("${module_name}::user_aliases_content", template("${module_name}/user_aliases.erb")),
  $cmnd_aliases_content = hiera("${module_name}::cmnd_aliases_content", template("${module_name}/cmnd_aliases.erb")),
  $runas_spec_content   = hiera("${module_name}::runas_spec_content", template("${module_name}/runas_spec.erb")),
) {
  ensure_packages('sudo', {'name' => $package_name})

  # Construct the main sudoers file in parts.
  concat { $sudoers_file:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0440',
    warn    => true,
    require => Package['sudo'],
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

  concat::fragment { 'includedirs':
    content => template("${module_name}/include_dirs.erb"),
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

  # Ensure any changes to sudoers is noted by rkhunter if installed.
  if defined(Package['rkhunter']) {
    exec { 'rkhunter-propupd sudo':
      command     => '/usr/bin/rkhunter --propupd sudo',
      refreshonly => true,
      timeout     => 3600,
      require     => Package['rkhunter'],
      subscribe   => Exec["Syntax check for ${sudoers_file}"]
    }
  }

  # Make sure privileges don't persist across reboots
  service { 'sudo':
    name       => $service_name,
    enable     => true,
    hasrestart => false,
    hasstatus  => false,
    require    => Package['sudo'],
  }
}
