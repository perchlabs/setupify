## Setupify Provisioning Tool

Setupify is a collection of bash scripts for provisioning a system. The included scripts emphasizes PHP and Zephir based tech, although it could be adapted to any use.  The bash scripts use only the most typical shell commands and so they should be portable to any modern Unix-like environment. Also included is a robust and optional `dialog` or `whiptail` shell menu program. One huge benefit of using Setupify as your starting point (other than it being awesome) is that you can easily transition from PHP to Zephir based development.

#### Intended Uses
* Quick and flexible provisioning of a Zephir/Phalcon testing or development environment
* As a starting point for provisioning a prioprietary application stack. In this case its a simple matter to delete sections and files before starting your enhancements.
* As a starting point for any open source Phalcon or Zephir based tech stack

#### Installer Definitions
Setupify is based around environment variable install definitions that are exported from one of the three settings files or from the parent shell. For example the `PHALCON_INSTALLER` variable describes both the method and version for installing Phalcon.  The install var is broken into two or three colon delineated sections depending on the install method.  Some install methods need more information than others.

Here is the default Phalcon install definition.  It states that Phalcon should be installed from the official stable repository.

```bash
PHALCON_INSTALLER=repository:stable
```

Here is a Phalcon install definition for installing from the 4.0.0-alpha1 tarball from the official releases.

```bash
PHALCON_INSTALLER=tarball:4.0.0-alpha1
```

This installs the same version but instead uses the tarball URL.

```bash
PHALCON_INSTALLER=tarball:https://github.com/phalcon/cphalcon/archive/v4.0.0-alpha1.tar.gz
```

It can also be used to install from a downloaded tarball.

```bash
PHALCON_INSTALLER=tarball:file:///home/dschissler/v4.0.0-alpha1.tar.gz
```

Finally here is a git example.  Notice that there are three sections delineated by a colon.  Note that it reads from the left and so the colon in the `https:` is ignored.

```bash
PHALCON_INSTALLER=git:3.4.x:https://github.com/cphalcon/cphalcon.git
```

For Zephir lets look at the installer method for using a PHAR program.

```bash
ZCOMPILER_INSTALLER=phar:0.11.9
```

Again a full URL can be used

```bash
ZCOMPILER_INSTALLER=phar:https://github.com/phalcon/zephir/releases/download/0.11.9/zephir.phar
```

#### How to start
In the `setup/` directory there are three files; `menu.sh`, `provision.sh` and `settings.sh`.

By running `./setup/menu.sh` or `./setup/provision.sh` without any arguments you will see the following:

```
dschissler@setupify:~/setupify$ ./setup/provision.sh
An OS name must be specified for provisioning.
Possible OS names include:
ubuntu1804
```

So you would run `./setup/provision.sh ubuntu1804` to start the automated provisioning and `./setup/menu.sh ubuntu1804` for a menu assisted provisioning.

Inside the `setup/settings.sh` file you will see something like the following:

```bash
# Turn on the PHP SAPIs, default is cli only.
# PHP_SAPI_LIST="cli fpm"
# PHP_SAPI_LIST="cli apache2"

# Manualy set the zephir_parser install.
# ZPARSER_INSTALLER=git:development:https://github.com/phalcon/php-zephir-parser.git

# Manually set the Zephir install
# ZCOMPILER_INSTALLER=git:development:https://github.com/phalcon/zephir.git
# ZCOMPILER_INSTALLER=tarball:0.11.8

# Manually set the Phalcon install.
# PHALCON_INSTALLER=git:4.0.x:git@github.com:phalcon/cphalcon.git
# PHALCON_INSTALLER=git:4.0.x:https://github.com/cphalcon/cphalcon.git
# PHALCON_INSTALLER=repository:mainline
# PHALCON_INSTALLER=repository:nightly
# PHALCON_INSTALLER=tarball:4.0.0-alpha1
# PHALCON_INSTALLER=tarball:https://github.com/phalcon/cphalcon/archive/v4.0.0-alpha1.tar.gz
```

You can comment out any line to change the setting. You won't need to do an `export` call on these lines since these files are sourced with `set -a`. You may export any of these values from a parent shell and they will be used unless overridden.

For example enter the following shell commands to change the Phalcon repository to `mainline` without modifying `setup/settings.sh`:

```
dschissler@setupify:~/setupify$ export PHALCON_INSTALLER=repository:mainline
dschissler@setupify:~/setupify$ ./setup/provision.sh ubuntu1804
```

#### Powerful conf.d provisioning stages

Setupify provides powerful staged init scripts for configuring the system package manager, zephir_parser, Zephir and Phalcon.  These do quite a lot out of the box but likely you will be needing to enhance these scripts or to add entirely new ones to augment the provisioning capabilities.

To start look at the `setup/os/ubuntu1804/` directory.  You will see one file; `os.sh` and three directories `conf.d/`, `functions/` and `lists/`.

**Basic OS Parts**

* `os.sh` defines operating specific settings. If you port setupify to a new OS or add capabilities to your init scripts then you'll likely want to change some of the settings.
* `functions/` defines OS specific functions.  Define functions here and they will be available in the init scripts.
* `lists/` stores basic lists like package names. Inside is the `package` and `pecl` files which simply list out the packages to install. This way you don't need to define your package lists in bash code. You can comment out lines in the lists by starting them with a hash.

**conf.d Init Scripts**
The `conf.d/` directory is filled with number ordered executable scripts. For example script `00-foo.sh` runs before `01-fee.sh`. If ordering is an important matter then it is advised to not rely on alphabetic ordering of the name part but to instead assign the script a different numbered prefix.

Out of the box the init scripts currently installs; system packages, PECL packages, zephir_parser, Zephir and Phalcon. At the moment you will need to setup a database and web server yourself. There are just two many combinations for an initial release.

**Skip Sections**

The conf.d init scripts can be skipped from the provisioning steps by defining a `SKIP_` environment variable. For example to skip PECL downloading, compiling and installation you can define `SKIP_PECL=1` in the parent shell or setting files.  Here is a look at the top of the `31-pecl.sh` conf.d script as an example of how it is skipped.

```bash
#!/usr/bin/env bash
[[ ! -z "$SKIP_PECL" ]] && exit 0
```

Skipping sections can be exceedingly useful when developing new tech or testing your custom provisioning steps. If the answer to the question *"Do I really want to wait for Phalcon to compile each time?"* is a *"No!"* then consider using `SKIP_` variables. At the moment the following skip steps are available: `SKIP_PACKAGES`, `SKIP_PECL`. You may define these skip steps in the parent shell or in your `settings.sh` config.

Additionally a low tech way to skip an entire conf.d init script is to temporary rename it be prefixed with the hash character. For example renaming `01-foo.sh` to `#01-foo.sh` will cause it be ignored. This is a great low tech way to debug your custom conf.d scripts.

**Init Script Failure**

Sometimes your init scripts will fail.  If any init script exits with a value other than `0` then the provisioning will be halted with an error message of the offending script.

### Menu Assisted Provisioning
Setupify includes a powerful `dialog` or `whiptail` menu system that acts a help wizard as well as a tutorial on advantage usage. To run the menu program call `./setup/menu.sh ubuntu1804`.

You will see the overview screen.

![Setupify Menu Overview](https://github.com/perch-foundation/media-resources/raw/master/setupify/v0.1/overview.png)

Here you can review the current install settings. If you choose "Install" it will enter the automated provisioning in the exact same way as if you ran `./setup/provision.sh ubuntu1804`.  If you choose "Customize" then it will load a customization menu with an item for every file in the `./setup/lib/menu/` directory.

![Setupify Customize Overview](https://github.com/perch-foundation/media-resources/raw/master/setupify/v0.1/customize.png)

We'll first customize the Phalcon menu. Phalcon may be installed from; the official repository, tarball or git repository.

![Phalcon Install Method](https://github.com/perch-foundation/media-resources/raw/master/setupify/v0.1/phalcon-method.png)

To start with we'll explore the repository options. We'll choose the nightly channel.

![Phalcon Repository Channel](https://github.com/perch-foundation/media-resources/raw/master/setupify/v0.1/phalcon-repository.png)

Since we're developing a PHP extension that uses the latest Zephir language features we're going to want the latest tech straight out of the unfiltered mind of the demented Sergei Iakovlev.

We'll choose the "Git" installaton method.

![Zephir Install Method](https://github.com/perch-foundation/media-resources/raw/master/setupify/v0.1/zcompiler-method.png)

Enter the URL to the Zephir git repository. The default value should be the official Zephir location. If you were working on improving Zephir then you could choose your own forked repository.

![Zephir Git Url](https://github.com/perch-foundation/media-resources/raw/master/setupify/v0.1/zcompiler-git-url.png)

Choose the default "development" repository.

![Zephir Git Branch](https://github.com/perch-foundation/media-resources/raw/master/setupify/v0.1/zcompiler-git-branch.png)

Next configure the zephir_parser installer.  Choose the default git options the same as the Zephir compiler.

![Zephir Git Branch](https://github.com/perch-foundation/media-resources/raw/master/setupify/v0.1/zparser-method.png)

Finally we'll want to skip the `PACKAGES` and `PECL` related provision steps and so we'll check those two options. This sets the environment variables `SKIP_PACKAGESS=1` and `SKIP_PECL=1`. In this example we have already installed the system packags and compiled the PECL extensions and so skipping it will save time. This is most useful when developing so that you don't need to continually wait for irrelevant steps. If you are going to be performing an operation a great many times then you should store the `SKIP_` setting in `setup/settings.sh` so that you don't need to set it for each provisioning.

![Zephir Git Branch](https://github.com/perch-foundation/media-resources/raw/master/setupify/v0.1/skips.png)

Finally return to the Overview screen. Notice that the install methods are different than they first appeared. You are now ready to install using the non-default methods.

![Zephir Git Branch](https://github.com/perch-foundation/media-resources/raw/master/setupify/v0.1/overview-final.png)

#### Create Custom Menus

Setupify allows you to easily create custom menu items. The `setup/lib/menu.sh` file defines several reusable functions for use in your custom menus. The following functions are available; `menuTarball`, `menuGit`, `menuRepository`, `menuPhar`. To create a new custom menu item simple create a new .sh file in the `setup/lib/menu/` directory.

**Create a helloworld menu with installer definition**

First create an empty `setup/lib/menu/helloworld.sh` file. The file does't need to be set as executable since it will be sourced instead of run directly.

Finally run the following commands in your terminal.

```bash
export HELLOWORLD_INSTALLER=tarball:5.1.4
./setup/menu.sh ubuntu1804
```

Notice the `HELLOWORLD` in the status section as well as the `helloworld` menu item.

![Zephir Git Branch](https://github.com/perch-foundation/media-resources/raw/master/setupify/v0.1/customize-helloworld.png)

Note: This is a hack to quickly demonstrate how to add new setupify functionality. To do this properly you will need to follow the conventions laid out in `setup/lib/data.sh`. Additionally, you will most likely want to copy an existing menu file as your starting point.

#### License
Setupify is licensed under the terms of LGPL.

#### The Book

Buy my book! However, its a little late in the Phalcon v3 cycle so maybe just kind-of figure-out some-kind-of-way, to get it.

[![Best book I ever wrote](https://github.com/perch-foundation/media-resources/raw/master/phalcon-cookbook.jpg)](https://www.amazon.com/Phalcon-Cookbook-David-Schissler/dp/1784396885)
