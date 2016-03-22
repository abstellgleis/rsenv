# Rust version management with **rsenv**.

----

**UNMAINTAINED!**

Please use [multirust](https://github.com/brson/multirust) or [rsvm](https://github.com/sdepold/rsvm) instead.

----

Use rsenv to pick a Rust version for your application and guarantee
that your development environment matches production.

## Table of Contents

* [How It Works](#how-it-works)
  * [Understanding PATH](#understanding-path)
  * [Understanding Shims](#understanding-shims)
  * [Choosing the Rust Version](#choosing-the-rust-version)
  * [Locating the Rust Installation](#locating-the-rust-installation)
* [Installation](#installation)
  * [Basic GitHub Checkout](#basic-github-checkout)
    * [Upgrading](#upgrading)
  * [How rsenv hooks into your shell](#how-rsenv-hooks-into-your-shell)
  * [Installing Rust Versions](#installing-rust-versions)
  * [Uninstalling Rust Versions](#uninstalling-rust-versions)
* [Command Reference](#command-reference)
  * [rsenv local](#rsenv-local)
  * [rsenv global](#rsenv-global)
  * [rsenv shell](#rsenv-shell)
  * [rsenv versions](#rsenv-versions)
  * [rsenv version](#rsenv-version)
  * [rsenv rehash](#rsenv-rehash)
  * [rsenv which](#rsenv-which)
  * [rsenv whence](#rsenv-whence)
* [Development](#development)
  * [Version History](#version-history)
  * [License](#license)



## How It Works

At a high level, rsenv intercepts Rust commands using shim
executables injected into your `PATH`, determines which Rust version
has been specified by your application, and passes your commands along
to the correct Rust installation.



### Understanding PATH

When you run a command like `rust` or `rake`, your operating system
searches through a list of directories to find an executable file with
that name. This list of directories lives in an environment variable
called `PATH`, with each directory in the list separated by a colon:

    /usr/local/bin:/usr/bin:/bin

Directories in `PATH` are searched from left to right, so a matching
executable in a directory at the beginning of the list takes
precedence over another one at the end. In this example, the
`/usr/local/bin` directory will be searched first, then `/usr/bin`,
then `/bin`.



### Understanding Shims

rsenv works by inserting a directory of _shims_ at the front of your
`PATH`:

    ~/.rsenv/shims:/usr/local/bin:/usr/bin:/bin

Through a process called _rehashing_, rsenv maintains shims in that
directory to match every Rust command across every installed version
of Rust—`irb`, `gem`, `rake`, `rails`, `rust`, and so on.

Shims are lightweight executables that simply pass your command along
to rsenv. So with rsenv installed, when you run, say, `rake`, your
operating system will do the following:

* Search your `PATH` for an executable file named `rake`
* Find the rsenv shim named `rake` at the beginning of your `PATH`
* Run the shim named `rake`, which in turn passes the command along to
  rsenv



### Choosing the Rust Version

When you execute a shim, rsenv determines which Rust version to use by
reading it from the following sources, in this order:

1. The `RSENV_VERSION` environment variable, if specified. You can use
   the [`rsenv shell`](#rsenv-shell) command to set this environment
   variable in your current shell session.

2. The first `.rust-version` file found by searching the directory of the
   script you are executing and each of its parent directories until reaching
   the root of your filesystem.

3. The first `.rust-version` file found by searching the current working
   directory and each of its parent directories until reaching the root of your
   filesystem. You can modify the `.rust-version` file in the current working
   directory with the [`rsenv local`](#rsenv-local) command.

4. The global `~/.rsenv/version` file. You can modify this file using
   the [`rsenv global`](#rsenv-global) command. If the global version
   file is not present, rsenv assumes you want to use the "system"
   Rust—i.e. whatever version would be run if rsenv weren't in your
   path.



### Locating the Rust Installation

Once rsenv has determined which version of Rust your application has
specified, it passes the command along to the corresponding Rust
installation.

Each Rust version is installed into its own directory under
`~/.rsenv/versions`. For example, you might have these versions
installed:

* `~/.rsenv/versions/0.8/`
* `~/.rsenv/versions/0.9/`
* `~/.rsenv/versions/0.10-pre/`

Version names to rsenv are simply the names of the directories in
`~/.rsenv/versions`.



## Installation



### Basic GitHub Checkout

This will get you going with the latest version of rsenv and make it
easy to fork and contribute any changes back upstream.

1. Check out rsenv into `~/.rsenv`.

    ~~~ sh
    $ git clone https://github.com/asaaki/rsenv.git ~/.rsenv
    ~~~

2. Add `~/.rsenv/bin` to your `$PATH` for access to the `rsenv`
   command-line utility.

    ~~~ sh
    $ echo 'export PATH="$HOME/.rsenv/bin:$PATH"' >> ~/.bash_profile
    ~~~

    **Ubuntu Desktop note**: Modify your `~/.bashrc` instead of `~/.bash_profile`.

    **Zsh note**: Modify your `~/.zshrc` file instead of `~/.bash_profile`.

3. Add `rsenv init` to your shell to enable shims and autocompletion.

    ~~~ sh
    $ echo 'eval "$(rsenv init -)"' >> ~/.bash_profile
    ~~~

    _Same as in previous step, use `~/.bashrc` on Ubuntu, or `~/.zshrc` for Zsh._

4. Restart your shell so that PATH changes take effect. (Opening a new
   terminal tab will usually do it.) Now check if rsenv was set up:

    ~~~ sh
    $ type rsenv
    #=> "rsenv is a function"
    ~~~

5. _(Optional)_ Install [rust-build][], which provides the
   `rsenv install` command that simplifies the process of
   [installing new Rust versions](#installing-rust-versions).



#### Upgrading

If you've installed rsenv manually using git, you can upgrade your
installation to the cutting-edge version at any time.

~~~ sh
$ cd ~/.rsenv
$ git pull
~~~

To use a specific release of rsenv, check out the corresponding tag:

~~~ sh
$ cd ~/.rsenv
$ git fetch
$ git checkout v0.1.0
~~~



### How rsenv hooks into your shell

Skip this section unless you must know what every line in your shell
profile is doing.

`rsenv init` is the only command that crosses the line of loading
extra commands into your shell. Coming from RVM, some of you might be
opposed to this idea. Here's what `rsenv init` actually does:

1. Sets up your shims path. This is the only requirement for rsenv to
   function properly. You can do this by hand by prepending
   `~/.rsenv/shims` to your `$PATH`.

2. Installs autocompletion. This is entirely optional but pretty
   useful. Sourcing `~/.rsenv/completions/rsenv.bash` will set that
   up. There is also a `~/.rsenv/completions/rsenv.zsh` for Zsh
   users.

3. Rehashes shims. From time to time you'll need to rebuild your
   shim files. Doing this automatically makes sure everything is up to
   date. You can always run `rsenv rehash` manually.

4. Installs the sh dispatcher. This bit is also optional, but allows
   rsenv and plugins to change variables in your current shell, making
   commands like `rsenv shell` possible. The sh dispatcher doesn't do
   anything crazy like override `cd` or hack your shell prompt, but if
   for some reason you need `rsenv` to be a real script rather than a
   shell function, you can safely skip it.

Run `rsenv init -` for yourself to see exactly what happens under the
hood.

### Installing Rust Versions

The `rsenv install` command doesn't ship with rsenv out of the box, but
is provided by the [rust-build][] project. If you installed it either
as part of GitHub checkout process outlined above or via Homebrew, you
should be able to:

~~~ sh
# list all available versions:
$ rsenv install -l

# install a Rust version:
$ rsenv install 0.10-pre
~~~

Alternatively to the `install` command, you can download and compile
Rust manually as a subdirectory of `~/.rsenv/versions/`. An entry in
that directory can also be a symlink to a Rust version installed
elsewhere on the filesystem. rsenv doesn't care; it will simply treat
any entry in the `versions/` directory as a separate Rust version.

### Uninstalling Rust Versions

As time goes on, Rust versions you install will accumulate in your
`~/.rsenv/versions` directory.

To remove old Rust versions, simply `rm -rf` the directory of the
version you want to remove. You can find the directory of a particular
Rust version with the `rsenv prefix` command, e.g. `rsenv prefix
0.8`.

The [rust-build][] plugin provides an `rsenv uninstall` command to
automate the removal process.

## Command Reference

Like `git`, the `rsenv` command delegates to subcommands based on its
first argument. The most common subcommands are:

### rsenv local

Sets a local application-specific Rust version by writing the version
name to a `.rust-version` file in the current directory. This version
overrides the global version, and can be overridden itself by setting
the `RSENV_VERSION` environment variable or with the `rsenv shell`
command.

    $ rsenv local 0.8

When run without a version number, `rsenv local` reports the currently
configured local version. You can also unset the local version:

    $ rsenv local --unset

Previous versions of rsenv stored local version specifications in a
file named `.rsenv-version`. For backwards compatibility, rsenv will
read a local version specified in an `.rsenv-version` file, but a
`.rust-version` file in the same directory will take precedence.

### rsenv global

Sets the global version of Rust to be used in all shells by writing
the version name to the `~/.rsenv/version` file. This version can be
overridden by an application-specific `.rust-version` file, or by
setting the `RSENV_VERSION` environment variable.

    $ rsenv global 0.9

The special version name `system` tells rsenv to use the system Rust
(detected by searching your `$PATH`).

When run without a version number, `rsenv global` reports the
currently configured global version.

### rsenv shell

Sets a shell-specific Rust version by setting the `RSENV_VERSION`
environment variable in your shell. This version overrides
application-specific versions and the global version.

    $ rsenv shell 0.10-pre

When run without a version number, `rsenv shell` reports the current
value of `RSENV_VERSION`. You can also unset the shell version:

    $ rsenv shell --unset

Note that you'll need rsenv's shell integration enabled (step 3 of
the installation instructions) in order to use this command. If you
prefer not to use shell integration, you may simply set the
`RSENV_VERSION` variable yourself:

    $ export RSENV_VERSION=0.10-pre

### rsenv versions

Lists all Rust versions known to rsenv, and shows an asterisk next to
the currently active version.

    $ rsenv versions
      0.8
    * 0.9 (set by /Users/sam/.rsenv/version)
      0.10-pre

### rsenv version

Displays the currently active Rust version, along with information on
how it was set.

    $ rsenv version
    0.8 (set by /Volumes/37signals/basecamp/.rust-version)

### rsenv rehash

Installs shims for all Rust executables known to rsenv (i.e.,
`~/.rsenv/versions/*/bin/*`). Run this command after you install a new
version of Rust, or install a gem that provides commands.

    $ rsenv rehash

### rsenv which

Displays the full path to the executable that rsenv will invoke when
you run the given command.

    $ rsenv which irb
    /Users/sam/.rsenv/versions/0.9/bin/irb

### rsenv whence

Lists all Rust versions with the given command installed.

    $ rsenv whence rackup
    0.8
    0.9
    0.10-pre

## Development

The rsenv source code is [hosted on
GitHub](https://github.com/asaaki/rsenv). It's clean, modular,
and easy to understand, even if you're not a shell hacker.

Tests are executed using [Bats](https://github.com/sstephenson/bats):

    $ bats test
    $ bats test/<file>.bats

Please feel free to submit pull requests and file bugs on the [issue
tracker](https://github.com/asaaki/rsenv/issues).



### Version History


**0.1.0** (201-03-02)

* Initial public release.



### License

(The MIT license)

Copyright (c) 2014 Christoph Grabo

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


  [rust-build]: https://github.com/asaaki/rust-build#readme
