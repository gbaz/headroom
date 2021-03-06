<p align="center"><img src ="https://github.com/vaclavsvejcar/headroom/blob/master/doc/assets/logo.png?raw=true" width="200" /></p>

[![Build Status](https://travis-ci.com/vaclavsvejcar/headroom.svg?branch=master)](https://travis-ci.com/vaclavsvejcar/headroom)
[![Hackage version](http://img.shields.io/hackage/v/headroom.svg)](https://hackage.haskell.org/package/headroom)
[![Stackage version](https://www.stackage.org/package/headroom/badge/lts?label=Stackage)](https://www.stackage.org/package/headroom)

Would you like to have nice, up-to-date license/copyright headers in your source code files but hate to manage them by hand? Then __Headroom__ is the right tool for you! Now you can define your license header as [Mustache][web:mustache] template, put all the variables (such as author's name, year, etc.) into the [YAML][wiki:yaml] config file and Headroom will take care to add such license headers to all your source code files.

[![asciicast](https://asciinema.org/a/4Pfxdss0V4msFjjt2z6mgCZCp.svg)](https://asciinema.org/a/4Pfxdss0V4msFjjt2z6mgCZCp)

__Table of Contents__
<!-- TOC -->

- [1. Main Features](#1-main-features)
- [2. Planned Features](#2-planned-features)
- [3. Installation](#3-installation)
    - [3.1. From Homebrew](#31-from-homebrew)
    - [3.2. From Pre-built Binaries](#32-from-pre-built-binaries)
    - [3.3. From Source Code](#33-from-source-code)
        - [3.3.1. Using Cabal](#331-using-cabal)
        - [3.3.2. Using Stack](#332-using-stack)
- [4. Basic Overview](#4-basic-overview)
    - [4.1. Main Concepts](#41-main-concepts)
    - [4.2. License Header Detection](#42-license-header-detection)
- [5. Quick Start Guide](#5-quick-start-guide)
    - [5.1. Initializing Headroom](#51-initializing-headroom)
        - [5.1.1. Automatic Initialization](#511-automatic-initialization)
        - [5.1.2. Manual Initialization](#512-manual-initialization)
    - [5.2. Running Headroom](#52-running-headroom)
- [6. Headroom Configuration](#6-headroom-configuration)
    - [6.1. YAML configuration file](#61-yaml-configuration-file)
    - [6.2. Command Line Arguments](#62-command-line-arguments)
- [7. Configuration Tips](#7-configuration-tips)
    - [7.1. Adding blank lines before/after license header](#71-adding-blank-lines-beforeafter-license-header)
    - [7.2. Putting license header before/after selected pattern](#72-putting-license-header-beforeafter-selected-pattern)
        - [7.2.1. put-before option](#721-put-before-option)
        - [7.2.2. put-after option](#722-put-after-option)
- [8. Command Line Interface Overview](#8-command-line-interface-overview)
    - [8.1. Init Command](#81-init-command)
    - [8.2. Run Command](#82-run-command)
    - [8.3. Generator Command](#83-generator-command)
        - [8.3.1. Supported License Types](#831-supported-license-types)
        - [8.3.2. Supported File Types](#832-supported-file-types)

<!-- /TOC -->

## 1. Main Features
- __License Header Management__ - allows to add, replace or drop license headers in source code files.
- __Flexible Header Detection__ - you can even replace or drop license headers that weren't generated by Headroom, as they are automatically detected from source code files, not from template files.
- __Fully Customizable__ - would you like to put empty lines before/after header? Or use different style of comments for your headers? No problem, you can change this in configuration.
Headroom, as they are automatically detected from source code files, not from template files.
- __Template Generator__ - generates license header templates for most popular _open source_ licenses. You can use these as-is, customize them or ignore them and use your custom templates.
- __Automatic Initialization__ - using the _Init_ command, _Headroom_ can detect what source code files you have in your project and generate initial configuration file and appropriate template skeletons.

## 2. Planned Features
- [[#25]][i25] __Content-aware Templates__ - license header templates will be able to extract some template variables from source code file for which the template is rendered
- [[#30]][i30] __Workflow without .headroom.yaml__ - add option to run Headroom without the `.headroom.yaml` and template files

## 3. Installation

### 3.1. From Homebrew
If you use _macOS_, you can install Headroom easily from [Homebrew][web:homebrew] using the following command:

```
$ brew install norcane/tools/headroom
```

### 3.2. From Pre-built Binaries
Pre-built binaries _(64bit)_ are available for _Linux_ and _macOS_ and can be downloaded for selected release from [releases page][meta:releases].

### 3.3. From Source Code
Headroom is written in [Haskell][web:haskell], so you can install it from source code either using [Cabal][web:cabal] or [Stack][web:stack].

#### 3.3.1. Using Cabal
1. install [Cabal][web:cabal] for your platform
1. run `cabal install headroom`
1. add `$HOME/.cabal/bin` to your `$PATH`

#### 3.3.2. Using Stack
1. install [Stack][web:stack] for your platform
1. clone this repository
1. run `stack install` in the project directory
1. add `$HOME/.local/bin` to your `$PATH`

## 4. Basic Overview

### 4.1. Main Concepts
1. __Template files__ - Template files contains templates in [Mustache][web:mustache] format, used for rendering license headers. During rendering phase, all variables are replaced by values loaded from _YAML_ configuration file. Each supported source code file has unique template, because license headers may differ for individual programming languages (i.e. different syntax for comments, etc.).
1. __Source Code Files__ - Headroom automatically discovers individual source code files in configured location and can manage (add/remove/drop) license headers in supported types of source code files.
1. __Variables__ - are defined in _YAML_ configuration file and these values are used to replace variables present in the template files.

### 4.2. License Header Detection
Unlike many other tools, Headroom can not only add, but also replace or drop existing license headers in source code files, even if there is already some header not generated by Headroom. This is done by implementing unique detection logic for each individual supported file type, but usually it's expected that the very first block comment is the license header. If you miss support for your favorite file type, please [open new issue][meta:new-issue].

## 5. Quick Start Guide
Let's demonstrate how to use Headroom in real world example: assume you have small source code repository with following structure and you'd like to setup Headroom for it:

```
project/
  └── src/
      ├── scala/
      │   ├── Foo.scala
      │   └── Bar.scala
      └── html/
          └── template1.html
```

### 5.1. Initializing Headroom

#### 5.1.1. Automatic Initialization
Easiest and fastest way how to initialize Headroom for your project is to use the `init` command, which generates all the boilerplate for you. The only drawback is that you can use it only in case that you use any supported open source license for which Headroom contains license header templates:

```shell
cd project/
headroom init -l bsd3 -s src/
```

This command will automatically scan source code directories for supported file types and will generate:
1. `.headroom.yaml` configuration file with correctly set path to template files, source codes and will contain dummy values for variables.
1. `headroom-templates/` directory which contains template files for all known file types you use in your project and for open source license you choose.

Now the project structure will be following:

```
project/
  ├── src/
  │   ├── scala/
  │   │   ├── Foo.scala
  │   │   └── Bar.scala
  │   └── html/
  │       └── template1.html
  ├── headroom-templates/
  │   ├── html.mustache
  │   └── scala.mustache
  └── .headroom.yaml
```

#### 5.1.2. Manual Initialization
If you for some reason don't want to use the automatic initialization using the steps above, you can either create all the required files (_YAML_ configuration and template files) by hand, or you can use the `gen` command to do that in semi-automatic way:

```shell
cd project/
headroom gen -c >./.headroom.yaml

mkdir headroom-templates/
cd headroom-templates/

headroom gen -l bsd3:css >./css.mustache
headroom gen -l bsd3:html >./html.mustache
headroom gen -l bsd3:scala >./scala.mustache
```

After these steps, make sure you set correctly the paths to template files and source code files in the _YAML_ configuration file.

### 5.2. Running Headroom
After you successfully initialized _Headroom_ for your project and the _template paths_, _source paths_ and _variables_ are correctly set, you can run _Headroom_ by executing one of the following commands:

```shell
cd project/
headroom run      # call the set run mode (by default the same as 'headroom run -a')
headroom run -a   # adds license headers to source code files
headroom run -r   # adds or replaces existing license headers
headroom run -d   # drops existing license headers from files
```

## 6. Headroom Configuration
Headroom uses three different sources of configuration, where the next one eventually overrides the previous one:

1. default configuration in [embedded/default-config.yaml][file:embedded/default-config.yaml]
1. custom configuration in `.headroom.yaml`
1. command line arguments

### 6.1. YAML configuration file
To check available configuration options for `.headroom.yaml`, see the [embedded/default-config.yaml][file:embedded/default-config.yaml] file, which is well documented and then override/define configuration you need in your project `.headroom.yaml`.

### 6.2. Command Line Arguments
Not all configuration options can be set/overridden using the command line arguments, but below is the list of matching _YAML_ options and command line options:

| YAML option         | Command Line Option            |		
|---------------------|--------------------------------|		
| `run-mode: add`     | `-a`, `--add-headers`          |		
| `run-mode: drop`    | `-d`, `--drop-headers`         |		
| `run-mode: replace` | `-r`, `--replace-headers`      |		
| `source-paths`      | `-s`, `--source-path=PATH`     |	
| `excluded-paths`    | `-e`, `--excluded-path=REGEX`  |	
| `template-paths`    | `-t`, `--template-path=PATH`   |
| `variables`         | `-v`, `--variable="KEY=VALUE"` |

Where `source-path`, `template-path` and `variable` command line arguments can be used multiple times to set more values.

## 7. Configuration Tips
This chapter contains tips on the most common configuration changes you may want to use in your project.

### 7.1. Adding blank lines before/after license header
If you want to configure Headroom to put blank lines before or after (or both) the license header, you can use following _YAML_ configuration:

```yaml
license-headers:
  <FILE_TYPE>:
    margin-after: 1   # number of blank lines to put after license header
    margin-before: 1  # number of blank lines to put before license header
```

### 7.2. Putting license header before/after selected pattern
If you need to put the license header before, after (or both) selected patterns, e.g. before the `package foo.bar` line in _Java_ files or after the _language pragmas_ in _Haskell_ files, you can use the `put-before` and/or `put-after` configuration keys.

#### 7.2.1. put-before option
`put-before` accepts list of regular expressions and the license header is placed before the very first line matching one of the given expressions.

__Example configuration:__
```yaml
license-headers:
  c:
    put-before: ["^#include"]
```

__Result:__
```c
/* >>> header is placed here <<< */
#include <stdio.h>
#include <foo.h>
int main() { ... }
```

#### 7.2.2. put-after option
`put-after` accepts list of regular expressions and the license header is placed after the very last line matching one of the given expressions.

__Example configuration:__
```yaml
license-headers:
  c:
    put-after: ["^#include"]
```

__Result:__
```c
#include <stdio.h>
#include <foo.h>
/* >>> header is placed here <<< */
int main() { ... }
```

## 8. Command Line Interface Overview
Headroom provides various commands for different use cases. You can check commands overview by performing following command:

```
$ headroom --help
headroom, v0.2.0.0 :: https://github.com/vaclavsvejcar/headroom

Usage: headroom COMMAND
  manage your source code license headers

Available options:
  -h,--help                Show this help text

Available commands:
  run                      add or replace source code headers
  gen                      generate stub configuration and template files
  init                     initialize current project for Headroom
```

### 8.1. Init Command
Init command is used to initialize Headroom for project by generating all the required files (_YAML_ config file and template files). You can display available options by running following command:

```
$ headroom init --help
Usage: headroom init (-l|--license-type TYPE) (-s|--source-path PATH)
  initialize current project for Headroom

Available options:
  -l,--license-type TYPE   type of open source license, available options:
                           apache2, bsd3, gpl2, gpl3, mit, mpl2
  -s,--source-path PATH    path to source code file/directory
  -h,--help                Show this help text
```

### 8.2. Run Command
Run command is used to manipulate (add, replace or drop) license headers in source code files. You can display available options by running following command:

```
$ headroom run --help
Usage: headroom run [-s|--source-path PATH] [-e|--excluded-path REGEX] 
                    [-t|--template-path PATH] [-v|--variable KEY=VALUE] 
                    [(-a|--add-headers) | (-r|--replace-headers) | 
                      (-d|--drop-headers)] [--debug] [--dry-run]
  add or replace source code headers

Available options:
  -s,--source-path PATH    path to source code file/directory
  -e,--excluded-path REGEX path to exclude from source code file paths
  -t,--template-path PATH  path to header template file/directory
  -v,--variable KEY=VALUE  value for template variable
  -a,--add-headers         only adds missing license headers
  -r,--replace-headers     force replace existing license headers
  -d,--drop-headers        drop existing license headers only
  --debug                  produce more verbose output
  --dry-run                execute dry run (no changes to files)
  -h,--help                Show this help text
```

### 8.3. Generator Command
Generator command is used to generate stubs for license header template and _YAML_ configuration file. You can display available options by running following command:

```
$ headroom gen --help
Usage: headroom gen [-c|--config-file] [-l|--license licenseType:fileType]
  generate stub configuration and template files

Available options:
  -c,--config-file         generate stub YAML config file to stdout
  -l,--license licenseType:fileType
                           generate template for license and file type
  -h,--help                Show this help text

```

When using the `-l,--license` option, you need to select the _license type_ and _file type_ from the list of supported ones listed bellow. For example to generate template for _Apache 2.0_ license and _Haskell_ file type, you need to use the `headroom gen -l apache2:haskell`.

#### 8.3.1. Supported License Types
Below is the list of supported _open source_ license types. If you miss support for license you use, feel free to [open new issue][meta:new-issue].

| License        | Used Name |
|----------------|-----------|
| _Apache 2.0_   | `apache2` |
| _BSD 3-Clause_ | `bsd3`    |
| _GPLv2_        | `gpl2`    |
| _GPLv3_        | `gpl3`    |
| _MIT_          | `mit`     |
| _MPL2_         | `mpl2`    |

#### 8.3.2. Supported File Types
Below is the list of supported source code file types. If you miss support for programming language you use, feel free to [open new issue][meta:new-issue].

| Language     | Used Name | Supported Extensions |
|--------------|-----------|----------------------|
| _C_          | `c`       | `.c`                 |
| _C++_        | `cpp`     | `.cpp`               |
| _CSS_        | `css`     | `.css`               |
| _Haskell_    | `haskell` | `.hs`                |
| _HTML_       | `html`    | `.html`, `.htm`      |
| _Java_       | `java`    | `.java`              |
| _JavaScript_ | `js`      | `.js`                |
| _Rust_       | `rust`    | `.rs`                |
| _Scala_      | `scala`   | `.scala`             |
| _Shell_      | `shell`   | `.sh`                |


[i25]: https://github.com/vaclavsvejcar/headroom/issues/25
[i30]: https://github.com/vaclavsvejcar/headroom/issues/30
[file:embedded/default-config.yaml]: https://github.com/vaclavsvejcar/headroom/blob/master/embedded/default-config.yaml
[meta:new-issue]: https://github.com/vaclavsvejcar/headroom/issues/new
[meta:releases]: https://github.com/vaclavsvejcar/headroom/releases
[web:bsd-3]: https://opensource.org/licenses/BSD-3-Clause
[web:cabal]: https://www.haskell.org/cabal/
[web:haskell]: https://haskell.org
[web:homebrew]: https://brew.sh
[web:mustache]: https://mustache.github.io
[web:stack]: https://www.haskellstack.org
[wiki:yaml]: https://en.wikipedia.org/wiki/YAML
