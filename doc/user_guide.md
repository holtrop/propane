${remove}
WARNING: This user guide is meant to be preprocessed and rendered by a custom
script.
The markdown source file is not intended to be viewed directly and will not
include all intended content.
${/remove}

#> Overview

Propane is an LR Parser Generator (LPG) which:

  * accepts LR(0), SLR, and LALR grammars
  * generates a built-in lexer to tokenize input
  * supports UTF-8 lexer inputs
  * generates a table-driven parser to parse input in linear time
  * is MIT-licensed
  * is distributable as a standalone Ruby script
  * supports D language

#> Installation

Propane is designed to be distributed as a stand-alone single file script that
can be copied into and versioned in a project's source tree.
The only requirement to run Propane is that the system has a Ruby interpreter
installed.
The latest release can be downloaded from [https://github.com/holtrop/propane/releases](https://github.com/holtrop/propane/releases).
Simply copy the `propane` executable script into the desired location within
the project to be built (typically the root of the repository) and mark it
executable.

#> Command Line Usage

Propane is typically invoked from the command-line as `./propane`.

    Usage: ./propane [options] <input-file> <output-file>
    Options:
      --log LOG   Write log file
      --version   Show program version and exit
      -h, --help  Show this usage and exit

The user must specify the path to a Propane input grammar file and a path to an
output file.
The generated source code will be written to the output file.
If a log file path is specified, Propane will write a log file containing
detailed information about the parser states and transitions.

#> Propane Grammar File

A Propane grammar file provides Propane with the patterns, tokens, grammar
rules, and user code blocks from which to build the generated lexer and parser.

#> License

Propane is licensed under the terms of the MIT License:

```
${include LICENSE.txt}
```

#> Contributing

Propane is developed on [github](https://github.com/holtrop/propane).

Issues may be submitted to [https://github.com/holtrop/propane/issues](https://github.com/holtrop/propane/issues).

Pull requests may be submitted as well:

  1. Fork it
  2. Create your feature branch (`git checkout -b my-new-feature`)
  3. Commit your changes (`git commit -am 'Add some feature'`)
  4. Push to the branch (`git push origin my-new-feature`)
  5. Create new Pull Request

#> Change Log

${changelog}
