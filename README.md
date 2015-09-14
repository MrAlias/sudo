# sudo

#### Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup](#setup)
    * [What sudo affects](#what-sudo-affects)
    * [Beginning with sudo](#beginning-with-sudo)
4. [Usage](#usage)
5. [Reference](#reference)
    * [Classes](#classes)
6. [Limitations](#limitations)

## Overview

Puppet module managing the Sudo package and all it's authorization capabilities.

## Module Description

This module attempts to provide basic management of the Sudo package and extended customizability of its configuration.  The module's intent is to supports declaration of data by traditional manifests as well as via hiera.

## Setup

### What sudo affects

* The sudo package.
* The main sudo configuration file (*/etc/sudoers*).
* The rkhunter database if the rkhunter package is installed.

### Beginning with sudo

To provide a basic setup all that is needed is something like this:

```puppet
include sudo
```

## Usage

### Providing custom configuration.

The `sudo` class can be declared with all the customized configuration options your project needs:

```puppet
class { 'sudo':
  defaults_content     => "Customized defaults content...",
  host_aliases_content => "Customized host_aliases content...",
  user_aliases_content => "Customized user_aliases content...",
  cmnd_aliases_content => "Customized cmnd_aliases content...",
  runas_spec_content   => "Customized runas_spec content...",
}
```

The above will handle correctly installing a sudoers file with the content provided.  If your content is incorrect syntax, the module will remove the sudoers file instead of installing a broken sudoers policy.

### Providing custom configuration in hiera.

The `sudo` class data can be defined in hiera.  In order to achieve the same result as the previous example showed, a file in your hierarchy should have something like this:

```yaml
---
...
sudo::defaults_content: "Customized defaults content..."
sudo::host_aliases_content: "Customized host_aliases content..."
sudo::user_aliases_content: "Customized user_aliases content..."
sudo::cmnd_aliases_content: "Customized cmnd_aliases content..."
sudo::runas_spec_content: "Customized runas_spec content..."
```

When the `sudo` class is then included in the project (via hiera or otherwise), a similar sudoers policy will be put in place.

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

## Limitations

This module has received limited testing on Debian based operating systems and CentOS 7.0.
