# osdev

THIS PROJECT IS A WORK IN PROGRESS

osdev is a pluggable bash script that automates a number of my OpenStack development
tasks. While the current plugins focus on automating a number of [OpenStack gerrit workflows](http://docs.openstack.org/infra/manual/developers.html),
the simple plugin approach can integrate with any scripting.

## Install

Clone the repo in the directory of your choice:
```
git clone https://github.com/bodenr/osdev.git
```

Set the following ENV vars (in your `.bashrc` or equivalent).
```
OSDEV_HOME=/path/to/cloned/osdev
PATH=${PATH}:${OSDEV_HOME}
```

If you have an IDE you wish to launch git repo dirs with (e.g. pycharm), also
set the following:
```
export OSDEV_PROJECT_LAUNCHER=/path/to/myexe
```

## Uninstall

* Remove the ENV vars you setup during installation.
* Delete the ``osdev`` git directory from installation.


## Usage

For a list of all plugin commands:
```
$ osdev
Usage: osdev <command> [<arg1> <arg2>...]
----------------------------------------------------
Commands (try 'osdev help' for more information)
----------------------------------------------------
amend <project> <change-id> [dir]
clone <project> [git-args]
rebase <repo-dir> [branch]
review <project> <change-id> [dir]
help [command]
----------------------------------------------------
```

For details on an individual command:
```
$ osdev help amend
amend (v1.0)
--------------------------------------------------------
Usage:        amend <project> <change-id> [dir]
Description:  Fetch the upstream https://github.com/openstack/ <project>
change (given by <change-id>) in preparation for amending it.
The topic branch will be set to the same topic name used in the
fetched change. If set, OSDEV_PROJECT_LAUNCHER /usr/local/pycharm-5.0.3/bin/pycharm.sh
will be used to launch the change directory.

Paramenters:
  change-id -- (Required) The gerrit change ID to retrieve for amending.
  project -- (Required) The github project name to checkout. For example 'neutron'.
  dir -- (Optional) The directory to clone the change into. Defaults to /tmp/<change-id>
--------------------------------------------------------
```

For details on all commands:
```
$ osdev help
Usage: osdev <command> [<arg1> <arg2>...]

Installed command plugins:

amend (v1.0)
--------------------------------------------------------
Usage:        amend <project> <change-id> [dir]
Description:  Fetch the upstream https://github.com/openstack/ <project>
change (given by <change-id>) in preparation for amending it.
The topic branch will be set to the same topic name used in the
fetched change. If set, OSDEV_PROJECT_LAUNCHER /usr/local/pycharm-5.0.3/bin/pycharm.sh
will be used to launch the change directory.

Paramenters:
  change-id -- (Required) The gerrit change ID to retrieve for amending.
  project -- (Required) The github project name to checkout. For example 'neutron'.
  dir -- (Optional) The directory to clone the change into. Defaults to /tmp/<change-id>
--------------------------------------------------------

clone (v1.0)
--------------------------------------------------------
Usage:        clone <project> [git-args]
Description:  Clone the upstream https://github.com/openstack/ <project>
optionally passing along git arugments. If set, OSDEV_PROJECT_LAUNCHER
/usr/local/pycharm-5.0.3/bin/pycharm.sh will be used to launch
the cloned project.

Paramenters:
  git-args -- (Optional) Additional arguments to pass onto the git clone command. Defaults to none.
  project -- (Required) The github project name to checkout. For example 'neutron'.
--------------------------------------------------------
...
```

## Creating new plugins

Have a look at the [existing plugins](plugins/) for how to implement the actual plugin
source file(s).

To add your plugins, choose one of following:

* Add your plugin(s) under the ``plugins`` dir of ``osdev``.
* Update the env var ``OSDEV_PLUGIN_PATHS`` to include a path to your plugin file(s) or directories
contain your plugins.

