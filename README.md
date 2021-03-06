## Setupify Provisioning Tool

**WARNING: Setupify is currently in a state of experimentation. Use tag release.**

Setupify is a collection of bash scripts for provisioning a system. The included scripts emphasizes PHP and Zephir based tech, although it could be adapted to any use.  The bash scripts use only the most typical shell commands and so they should be portable to any modern Unix-like environment. Also included is a robust and optional `dialog` or `whiptail` shell menu program. One huge benefit of using Setupify as your starting point is that you can easily transition from PHP to Zephir based development.

#### Intended Uses

* Quick and flexible provisioning of a Zephir/Phalcon environment for development or testing.
* As a starting point for provisioning a prioprietary application stack. In this case its a simple matter to delete sections and files before starting your enhancements.
* As a starting point for any open source Phalcon or Zephir based tech stack

#### How to start

In the `setup/` directory there are three files; `install`, `menu` and `settings`.

By running `./setup/install` without any arguments you will see the following:

```
dschissler@setupify:~/setupify$ ./setup/install
An OS name must be specified for provisioning.
Possible OS names include:
ubuntu1804
```

So you would run `./setup/install ubuntu1804` to start the automated provisioning. Setupify will first obtain sudo permissions for later use.

### Menu Assisted Provisioning

Setupify includes a powerful `dialog` or `whiptail` menu wizard. To run the menu program call:

`./setup/menu`

You will see a screen for choosing the operating system.

![Setupify Menu Overview](https://github.com/perch-foundation/media-resources/raw/master/setupify/v0.2/choose-os.png)

You may bypass this screen by supplying the operating system from the command line:

`./setup/menu ubuntu1804`

Next you will see the overview screen. Select the *"Load Everything"* entry.

![Setupify Menu Overview](https://github.com/perch-foundation/media-resources/raw/master/setupify/v0.2/overview-load-everything.png)

We'll choose the *"Customize"* menu item. Notice how the installers are now defined.

![Setupify Customize Overview](https://github.com/perch-foundation/media-resources/raw/master/setupify/v0.2/overview-customize.png)

If you were to choose *"Install"* at this point it would enter the automated provisioning in the exact same way as if you ran `./setup/install ubuntu1804`.

Instead we'll first customize the *"Phalcon"* installer. So *Overview* --> *Customize* --> *Phalcon*.

![Setupify Customize Overview](https://github.com/perch-foundation/media-resources/raw/master/setupify/v0.2/customize-hover-phalcon.png)

Phalcon may be installed from; the official repository, tarball or git repository. We'll choose the respository method.

![Phalcon Install Method](https://github.com/perch-foundation/media-resources/raw/master/setupify/v0.2/phalcon-method.png)

We'll choose the nightly channel. This is an easy way to get the latest Phalcon code.

![Phalcon Repository Channel](https://github.com/perch-foundation/media-resources/raw/master/setupify/v0.2/phalcon-repository.png)

Since we're developing a PHP extension that uses the latest Zephir language features we're going to want the latest tech.

We'll choose the *"Git"* installaton method.

![Zephir Install Method](https://github.com/perch-foundation/media-resources/raw/master/setupify/v0.2/zcompiler-method.png)

Enter the URL to the Zephir git repository. The default value should be the official Zephir location. If you were working on improving Zephir then you could choose your own forked repository.

![Zephir Git Url](https://github.com/perch-foundation/media-resources/raw/master/setupify/v0.2/zcompiler-git-url.png)

Choose the default *"development"* branch.

![Zephir Git Branch](https://github.com/perch-foundation/media-resources/raw/master/setupify/v0.2/zcompiler-git-branch.png)

In this example we'll pretend that we've already provisioned the system and so we'll want to skip some of the time intensive operations. Choose the *"Interests"* item from the *"Customize"* menu.

![Zephir Git Branch](https://github.com/perch-foundation/media-resources/raw/master/setupify/v0.2/customize-hover-interests.png)

Now make sure the `PACKAGES` and `PECL` check boxes are deselected. This will skip some some unnecessary steps. This is most useful when developing so that you don't need to continually wait for irrelevant processes.

![Zephir Git Branch](https://github.com/perch-foundation/media-resources/raw/master/setupify/v0.2/interests-all-unchecked.png)

Finally return to the Overview screen. Notice that the installer methods are different than they first appeared. You are now ready to provision using the non-default methods.

![Zephir Git Branch](https://github.com/perch-foundation/media-resources/raw/master/setupify/v0.2/overview-hover-ready-install.png)

#### Create Custom Menus

Setupify allows you to easily create custom menus. The `setup/lib/section/` directory contains sections which may each have an optional menu.  Setupify provides the following helper menus; `menuTarball`, `menuGit`, `menuRepository`, `menuPhar`. To create a new custom menu item simple create a new section directory and place a new menu file inside of it.

**Create a helloworld menu with installer default**

Create an empty `setup/lib/section/helloworld/menu_helloworld.sh` file. This file does't need to be set as executable since it will be sourced instead of run directly.

Create a data file `setup/lib/section/helloworld/data.sh`

```bash
HELLOWORLD_DEFAULT=tarball:555.5555
```

Notice the `HELLOWORLD` installer in the status section as well as the `helloworld` menu item.

![Zephir Git Branch](https://github.com/perch-foundation/media-resources/raw/master/setupify/v0.2/customize-helloworld.png)

Note: This is a hack to quickly demonstrate how to add new setupify functionality. To do this properly you will need to follow the conventions laid out in the other section menus in the `setup/lib/sections/` directory.

#### Installer Definitions
Setupify is based around environment variable installer definitions. For example the `PHALCON_INSTALLER` variable describes both the method and version for installing Phalcon.  The installer variable is broken into two or three colon delineated sections depending on the installer method.  Some installer methods need more information than others.

Here is the default Phalcon installer definition.  It states that Phalcon should be installed from the official stable repository.

```bash
PHALCON_INSTALLER=repository:stable
```

Here is a Phalcon installer definition for installing from the 4.0.5 tarball from the official releases.

```bash
PHALCON_INSTALLER=tarball:4.0.5
```

This installs the same version but instead uses the tarball URL.

```bash
PHALCON_INSTALLER=tarball:https://github.com/phalcon/cphalcon/archive/v4.0.5.tar.gz
```

It can also be used to install from a downloaded tarball.

```bash
PHALCON_INSTALLER=tarball:file:///home/dschissler/v4.0.5.tar.gz
```

Finally here is a git example.  Notice that there are three sections delineated by a colon.  Note that it reads from the left and so the colon in the `https:` is ignored.

```bash
PHALCON_INSTALLER=git:3.4.x:https://github.com/cphalcon/cphalcon.git
```

For Zephir lets look at the installer method for using a PHAR program.

```bash
ZCOMPILER_INSTALLER=phar:0.12.18
```

Again a full URL can be used

```bash
ZCOMPILER_INSTALLER=phar:https://github.com/phalcon/zephir/releases/download/0.12.18/zephir.phar
```

#### Alternative and more persistent settings

1) You may define your installers and other settings in `./setup/settings`.

2) You may also export your installer definitions from the shell. For example these commands will change the Phalcon repository to `mainline` without modifying `setup/settings`:

```
dschissler@setupify:~/setupify$ export PHALCON_INSTALLER=repository:mainline
dschissler@setupify:~/setupify$ ./setup/install ubuntu1804
```

This could be useful if you were going to be testing the provision many times from a single terminal.

#### Powerful init.d provisioning stages

Setupify provides powerful staged init scripts for configuring the system package manager, zephir_parser, Zephir and Phalcon.

To start look at the `setup/os/ubuntu1804/` directory.  You will see one file; `os.sh` and three directories `init.d/`, `functions/` and `lists/`.

**Basic OS Parts**

* `os.sh` defines operating specific settings. If you port setupify to a new OS or add capabilities to your init scripts then you'll likely want to change some of the settings.
* `functions/` defines OS specific functions.  Define functions here and they will be available in the init scripts.
* `lists/` stores basic lists like package names. Inside is the `package` and `pecl` files which simply list out the packages to install. This way you don't need to define your package lists in bash code. You can comment out lines in the lists by starting them with a hash.

**init.d Scripts**
The `init.d/` directory is filled with number ordered executable scripts. For example script `00-foo.sh` runs before `01-fee.sh`. If ordering is an important matter then it is advised to not rely on alphabetic ordering of the name part but to instead assign the script a different numbered prefix.

Out of the box the init scripts currently installs; system packages, PECL packages, zephir_parser, Zephir, Phalcon and Node.js. At the moment you will need to setup a database and web server yourself. There are just two many combinations for an initial release.

**Interest Sections**

You can create "interest" environment variables within your init.d scripts that will allow you to toggle the execution of blocks of code or to completely skip the contents of a script.  Setupify will scan your code for any `^[A-Z]+_INTEREST$` variable patterns in your code.

Here is a typical example of what happens when an interest is not defined:

```bash
[[ -z "$PECL_INTEREST" ]] && exit 0
```

There are two standard ways to use interests depending on if the `install` or `menu` script is used.

1) The `./setup/install` script is designed to be a one-stop-shop for installing a base system and so it will activate all interests in order to perform every operation.

2) Te `./setup/menu` script starts with all interests disabled in order to allow you to turn on individual interests during the development process.  You may turn on interests by specifying *"Load everything"* from the main menu or by enabling individual interests in the *"Interests"* customize menu.  This is a core philosophical feature of setupify in that it allows you to use the same provision script for deployment as well as trying out new software versions during development.

In order to achieve the desired usability of setupify, please make sure that any operations peformed in your init.d scripts are indepotent.  For example: that means if a user is added to something that running the script again will not have a negative effect on the system either; by first checking that the user exists or by checking that adding the user again will not break anything or result in multiple entries.  If you can test each system modification for initial install as well as when it is performed a second time then you will be able to enjoy a production provisioning system that also doubles as an amazing development tool.

Being able to manually define interests can be exceedingly useful when developing new tech or testing your custom provisioning steps. If the answer to the question *"Do I really want to wait for my PECL PHP extensions to compile each time that I check something?"* is a *"No!"* then consider not turning on that interests steps while running the `menu` script.

**Low tech script avoidance**

Additionally a low tech way to skip an entire init.d init script is to temporary rename it be prefixed with the hash character. For example renaming `01-foo.sh` to `#01-foo.sh` will cause it be ignored. This is a great low tech way of debugging your custom init.d scripts.

**Init Script Failure**

Sometimes your init scripts will fail.  If any init script exits with a value other than `0` then the provisioning will be halted with an error message of the offending script.

#### License
Setupify is licensed under the terms of LGPL v3.
