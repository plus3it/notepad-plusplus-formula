# notepad-plusplus-formula

A Saltstack formula designed to install and configure the [Notepad++](https://notepad-plus-plus.org/) text-editor (and to uninstall it later).

It is primarily expected that this formula will be run via [P3](https://www.plus3it.com/)'s "[watchmaker](https://watchmaker.readthedocs.io/en/stable/)" framework.

This formula is able to install and configure the Notepad++ text-editor on Windows-based systems. Linux functionality would also have been provided, but there's currently no Linux variant from the same makers.

## Available states

- [notepad-plusplus](#notepad-plusplus)
- [notepad-plusplus.clean](#notepad-plusplus.clean)
- [notepad-plusplus.package](#notepad-plusplus.package)
- [notepad-plusplus.package.clean](#notepad-plusplus.package.clean)
- [notepad-plusplus.config](#notepad-plusplus.config)
- [notepad-plusplus.config.clean](#notepad-plusplus.config.clean)

### notepad-plusplus

Executes the `package` and `config` states to install and configure the Notepad++ editor. This includes the editor binaries, as well as some Windows Registry settings and user-configuration template files.

### notepad-plusplus.clean

Executes the `package` and `config` states' `clean` actions to fully uninstall the Notepad++ editor and associated registry entries

### notepad-plusplus.package

Executes _just_ the `package` state to install the Notepad++ package.

### notepad-plusplus.package.clean

Executes _just_ the `package` state's `clean` module to uninstall the Notepad++ binaries.

### notepad-plusplus.config

Executes _just_ the `config` state to install registry-keys and other configuration-items to support the healthy running of the Notepad++ application

### notepad-plusplus.config.clean

Executes _just_ the `config` state's `clean` module to uninstall the Notepad++ application's registry keys and other configuration-items set up during a prior, formula-managed installation.
