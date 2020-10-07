# wsc-package-build-script
A lightweight but feature-rich Bash script for building WoltLab Suite™ Core packages.

## How to use
First of all, you must place the `build.sh` file in the root directory of your project. Then you need to create a `.packageinfo` file that contains basic information about the package, such as the filename of the archive to be created and optionally custom directories that need to be archived during the build process (e.g. `files_update`). Place the `.packageinfo` file in the same directory as the `build.sh` file.

A sample file that meets the minimum requirements would look like this:
```
packageIdentifier=software.krymo.woltlab.suite.core.sample
```

By default the build script recognizes directories named `acptemplates`, `files`, `style` and `templates` and automatically archives them.
Under certain circumstances, however, it may be necessary to archive additional directories during the build process. In this case you can simply extend the `.packageinfo` file:
```
packageIdentifier=software.krymo.woltlab.suite.core.sample
packageArchives=files_update;templates_update
```
Directories must be separated by semicolon (`;`). In this example two archives (`files_update.tar` and `templates_update.tar`) would be created with the contents of the directories with the same name.

You can find the package archive in the `build/` directory after running the build script.

## Please note when using a version control system
The build script utilizes the [`--exclude-vcs` option of GNU tar](https://www.gnu.org/software/tar/manual/html_node/exclude.html). This ensures that files that are excluded from being added to version control systems are also excluded from being added to the package archive. Nevertheless, you might want to adapt your ignore file to exclude the `build/` directory created by this build script.
