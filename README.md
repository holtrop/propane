# The Propane Parser Generator

Propane is a LALR Parser Generator (LPG) which:

  * accepts LR(0), SLR, and LALR grammars
  * generates a built-in lexer to tokenize input
  * supports UTF-8 lexer inputs
  * generates a table-driven shift/reduce parser to parse input in linear time
  * targets C, C++, or D language outputs
  * optionally supports automatic full parse tree generation
  * is MIT-licensed
  * is distributable as a standalone Ruby script

## Installation

Propane is designed to be distributed as a stand-alone single file script that
can be copied into and versioned in a project's source tree.
The only requirement to run Propane is that the system has a Ruby interpreter
installed.
The latest release can be downloaded from [https://github.com/holtrop/propane/releases](https://github.com/holtrop/propane/releases).

Simply copy the `propane` executable script into the desired location within
the project to be built (typically the root of the repository) and mark it
executable.

## Usage

### Command Line Interface

Propane is typically invoked from the command-line as `./propane`.

    Usage: ./propane [options] <input-file> <output-file>
    Options:
      -h, --help  Show this usage and exit.
      --log LOG   Write log file. This will show all parser states and their
                  associated shifts and reduces. It can be helpful when
                  debugging a grammar.
      --version   Show program version and exit.
      -w          Treat warnings as errors. This option will treat shift/reduce
                  conflicts as fatal errors and will print them to stderr in
                  addition to the log file.

The user must specify the path to a Propane input grammar file and a path to an
output file.
The generated source code will be written to the output file.
If a log file path is specified, Propane will write a log file containing
detailed information about the parser states and transitions.

### Propane Grammar File

A Propane grammar file provides Propane with the patterns, tokens, grammar
rules, and user code blocks from which to build the generated lexer and parser.

Example grammar file:

```
<<
import std.math;
>>

# Parser values are unsigned integers.
ptype ulong;

# A few basic arithmetic operators.
token plus /\+/;
token times /\*/;
token power /\*\*/;
token integer /\d+/ <<
  ulong v;
  foreach (c; match)
  {
    v *= 10;
    v += (c - '0');
  }
  $$ = v;
>>
token lparen /\(/;
token rparen /\)/;
# Drop whitespace.
drop /\s+/;

Start -> E1 << $$ = $1; >>
E1 -> E2 << $$ = $1; >>
E1 -> E1 plus E2 << $$ = $1 + $3; >>
E2 -> E3 << $$ = $1; >>
E2 -> E2 times E3 << $$ = $1 * $3; >>
E3 -> E4 << $$ = $1; >>
E3 -> E3 power E4 <<
  $$ = pow($1, $3);
>>
E4 -> integer << $$ = $1; >>
E4 -> lparen E1 rparen << $$ = $2; >>
```

Grammar files can contain comment lines beginning with `#` which are ignored.
White space in the grammar file is also ignored.

It is convention to use the extension `.propane` for the Propane grammar file,
however any file name is accepted by Propane.

See [https://holtrop.github.io/propane/index.html](https://holtrop.github.io/propane/index.html) for the full User Guide.

## Development

After checking out the repository, run `bundle install` to install dependencies.
Run `rake spec` to execute tests.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/holtrop/propane.

## License

Propane is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
