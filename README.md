# sudo

#### Table of Contents

1. [Module Description](#module-description)
2. [Setup](#setup)
    * [What sudo affects](#what-sudo-affects)
    * [Beginning with sudo](#beginning-with-sudo)
3. [Usage](#usage)
4. [Reference](#reference)
    * [Classes](#classes)
5. [Limitations](#limitations)

## Module Description

[Sudo](http://www.sudo.ws) is powerful tool used to manage extending users privileges.  This module is intended to offer extended customizability of sudo configuration in order to fully leverage its use.

## Setup

### What sudo affects

* The sudo package.
* The main sudo configuration file (*/etc/sudoers*).
* Potentially the rkhunter database if the rkhunter package is installed.

### Beginning with sudo

To install sudo with a basic configuration:

```puppet
include sudo
```

## Usage

### Providing custom configuration.

The `sudo` class is the main class of the module and is where all configuration is done.

```puppet
class { 'sudo':
  defaults_content     => 'Defaults	editor=/usr/bin/vim env_reset mail_badpass noexec',
  host_aliases_content => 'Host_Alias	SANS = backup1, backup2',
  user_aliases_content => 'User_Alias	PEONS = jim, joe, jack',
  cmnd_aliases_content => 'Cmnd_Alias	BACKUP = /bin/tar, /bin/cpio, /bin/mount',
  runas_spec_content   => 'PEONS	SANS = (admin) EXEC: BACKUP',
}
```

Of course if you need to add more complex content you can pass in a file or template output.

If the content of the created policy contains invalid syntax the module will remove the configuration file instead of installing a broken sudoers policy.

### Including your own custom files

If passing content to the main sudoers policy is not enough to achieve the desired configuration, you can directly manage the configuration files and just include them in the main policy.

```puppet
file { '/home/me/my_policies':
  ensure => directory,
}

file { '/home/me/my_policies/polity1':
  ensure  => file,
  content => tempate('/path/to/templates/polity1'),
  requre  => File['/home/me/my_policies'],
}

file { '/home/me/my_policies/policy2':
  ensure  => file,
  content => template('/path/to/templates/policy2'),
  requre  => File['/home/me/my_policies'],
}

class { 'sudo':
  include_dirs => ['/etc/sudoers.d', '/home/me/my_policies']
  requre       => File['/home/me/my_policies'],
}
```

### Configuring with Hiera

The `sudo` class was designed with the intent that hiera would be used in parameter definition.  If merging is enabled even more specific policy can be generated. Given a hierarchy like the following defined in `hiera.yaml`:

```yaml
---
:backends:
  - yaml
:hierarchy:
  - "role/%{::role}"
  - common
:yaml:
   :datadir: /etc/puppet/hieradata
:merge_behavior: deeper
```

A base configuration can be established in `common.yaml`:

```yaml
# common.yaml
---
sudo::defaults_content: 'Defaults	editor=/usr/bin/vim env_reset mail_badpass noexec',
sudo::host_aliases_content: 'Host_Alias	SANS = backup1, backup2,
sudo::user_aliases_content: 'User_Alias	PEONS = jim, joe, jack',
sudo::cmnd_aliases_content: 'Cmnd_Alias	BACKUP = /bin/tar, /bin/cpio, /bin/mount',
sudo::runas_spec_content: 'PEONS	SANS = (admin) EXEC: BACKUP',
```

Now if you want you the new guy, albert, to be able to only work on the demo servers:

```yaml
# role/demo.yaml
---
sudo::user_aliases_content: 'User_Alias	PEONS = jim, joe, jack, albert',
```

### Integration with rkhunter

[Rkhunter](http://rkhunter.sourceforge.net) is a great tool to help monitor system security.  It will, however, error if you update the sudoers policy without notifying it of the change.  This module does that for you if you say to:

```puppet
class { 'sudo':
  runas_spec_content => '%sudo	ALL = (ALL:ALL) ALL',
  update_rkhunter    => true,
}
```

## Reference

### Classes

#### sudo

Manages the Sudo package and its authorization capabilities.

##### `sudo::package_name`

(String) Name of sudo package the module will install.

Default value: `'sudo'`

##### `sudo::sudoers_file`

(Absolute Path) Location of the main sudoers configuration file.

Default value: `'/etc/sudoers'`

##### `sudo::include_dirs`

(Array) Directories to include in the main sudoers file.

All additional files found in these directories are treated as sudo configuration files.

Default value: `['/etc/sudoers.d']`

##### `sudo::defaults_content`

(String) Content of the defaults section of the sudoers file.

##### `sudo::host_aliases_content`

(String) Content of the host\_aliases section of the sudoers file.

##### `sudo::user_aliases_content`

(String) Content of the user\_aliases section of the sudoers file.

##### `sudo::cmnd_aliases_content`

(String) Content of the cmnd\_aliases section of the sudoers file.

##### `sudo::runas_spec_content`

(String) Content of the runas\_spec section of the sudoers file.

##### `sudo::update_rkhunter`

(Boolean) Specify if rkhunter should be updated after any change is made.

Any changes to the sudoers policy will cause rkhunter to error.  This provides a convenient way to automatically update rkhunter of changes to the sudoers policy.

Default value: `false`

## Limitations

This module has received limited testing on Debian based operating systems and CentOS 7.0.
