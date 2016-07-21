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
* Delete the ``~/.osdev`` directory.


## Usage

For a list of all plugin commands:
```
$ osdev
Usage: osdev <command> [<arg1> <arg2>...]
----------------------------------------------------
Commands (try 'osdev help' for more information)
----------------------------------------------------
eget [name]
eset [name] [value]
amend --dir <dir> [change_id] <project>
clone --dir <dir> <project> <branch>
new --dir <dir> --depends_id <depends_id> <project> [topic]
rebase --project <project> --branch <branch> [dir_or_change]
review --dir <dir> <project> [change_id]
help [command]
project [project_name]
----------------------------------------------------
```

For details on an individual command:
```
$ osdev help amend
--------------------------------------------------------
Plugin:
    amend (v1.0)

Usage:
    osdev amend --dir <dir> [change_id] <project>

Description:
Clone the upstream [project] and fetch the said [change-id] atop
it in preparation for amending. If specified, the said <dir> will be
used, otherwise 'OSDEV_LONG_TERM_DIR' /home/boden/src/python/ is used.
If defined, the cloned [project] will be launched via 'OSDEV_PROJECT_LAUNCHER'
/usr/local/pycharm-5.0.3/bin/pycharm.sh once cloned.

Optional Parameters:
    dir -- The directory to clone the change into. Defaults to /tmp/<change-id>
--------------------------------------------------------

```

For details on all commands:
```
$ osdev help
Usage: osdev <command> [<arg1> <arg2>...]

Installed command plugins:

--------------------------------------------------------
Plugin:
    eget (v1.0)

Usage:
    osdev eget [name]

Description:
Prints osdev environment variables. If [name] is given the said
variable's current value is printed. If [name] is not given
all current OSDEV env variables are printed. When [name] is specified
it is automatically converted to the form OSDEV_<name>

Optional Parameters:
--------------------------------------------------------

--------------------------------------------------------
Plugin:
    eset (v1.0)

Usage:
    osdev eset [name] [value]

Description:
Sets the OSDEV env variable [name] to [value]. This setting is
persisted in /home/boden/.osdev//.osdevrc.

Optional Parameters:
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

