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
  * target C or D language outputs
  * is MIT-licensed
  * is distributable as a standalone Ruby script

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

Example grammar file:

```
<<
import std.math;
>>

ptype ulong;

token plus /\\+/;
token times /\\*/;
token power /\\*\\*/;
token integer /\\d+/ <<
  ulong v;
  foreach (c; match)
  {
    v *= 10;
    v += (c - '0');
  }
  $$ = v;
>>
token lparen /\\(/;
token rparen /\\)/;
drop /\\s+/;

Start -> E1 <<
  $$ = $1;
>>
E1 -> E2 <<
  $$ = $1;
>>
E1 -> E1 plus E2 <<
  $$ = $1 + $3;
>>
E2 -> E3 <<
  $$ = $1;
>>
E2 -> E2 times E3 <<
  $$ = $1 * $3;
>>
E3 -> E4 <<
  $$ = $1;
>>
E3 -> E3 power E4 <<
  $$ = pow($1, $3);
>>
E4 -> integer <<
  $$ = $1;
>>
E4 -> lparen E1 rparen <<
  $$ = $2;
>>
```

##> User Code Blocks

User code blocks begin with the line following a "<<" token and end with the
line preceding a grammar line consisting of solely the ">>" token.
All text lines in the code block are copied verbatim into the output file.

### Standalone Code Blocks

C example:

```
<<
#include &lt;stdio.h>
>>
```

D example:

```
<<
import std.stdio;
>>
```

Standalone code blocks are emitted early in the output file as top-level code
outside the context of any function.
Standalone code blocks are a good place to include/import any other necessary
supporting code modules.
They can also define helper functions that can be reused by lexer or parser
user code blocks.
They are emitted in the order they are defined in the grammar file.

For a C target, the word "header" may immediately follow the "<<" token to
cause Propane to emit the code block in the generated header file rather than
the generated implementation file.
This allows including another header that may be necessary to define any types
needed by a `ptype` directive, for example:

```
<&lt;header
#include "mytypes.h"
>>
```

### Lexer pattern code blocks

Example:

```
ptype ulong;

token integer /\\d+/ <<
  ulong v;
  foreach (c; match)
  {
    v *= 10;
    v += (c - '0');
  }
  $$ = v;
>>
```

Lexer code blocks appear following a `token` or `pattern` expression.
User code in a lexer code block will be executed when the lexer matches the
given pattern.
Assignment to the `$$` symbol will associate a parser value with the lexed
token.
This parser value can then be used later in a parser rule.

### Parser rule code blocks

Example:

```
E1 -> E1 plus E2 <<
  $$ = $1 + $3;
>>
```

Parser rule code blocks appear following a rule expression.
User code in a parser rule code block will be executed when the parser reduces
the given rule.
Assignment to the `$$` symbol will associate a parser value with the reduced
rule.
Parser values for the rules or tokens in the rule pattern can be accessed
positionally with tokens `$1`, `$2`, `$3`, etc...

##> Specifying parser value types - the `ptype` statement

The `ptype` statement is used to define parser value type(s).
Example:

```
ptype void *;
```

This defines the default parser value type to be `void *` (this is, in fact,
the default parser value type if the grammar file does not specify otherwise).

Each defined lexer token type and parser rule has an associated parser value
type.
When the lexer runs, each lexed token has a parser value associated with it.
When the parser runs, each instance of a reduced rule has a parser value
associated with it.
Propane supports using different parser value types for different rules and
token types.
The example `ptype` statement above defines the default parser value type.
A parser value type name can optionally be specified following the `ptype`
keyword.
For example:

```
ptype Value;
ptype array = Value[];
ptype dict = Value[string];

Object -> lbrace rbrace <<
  $$ = new Value();
>>

Values (array) -> Value <<
  $$ = [$1];
>>
Values -> Values comma Value <<
  $$ = $1 ~ [$3];
>>

KeyValue (dict) -> string colon Value <<
  $$ = [$1: $3];
>>
```

In this example, the default parser value type is `Value`.
A parser value type named `array` is defined to mean `Value[]`.
A parser value type named `dict` is defined to mean `Value[string]`.
Any defined tokens or rules that do not specify a parser value type will have
the default parser value type associated with them.
To associate a different parser value type with a token or rule, write the
parser value type name in parentheses following the name of the token or rule.
In this example:

  * a reduced `Object`'s parser value has a type of `Value`.
  * a reduced `Values`'s parser value has a type of `Value[]`.
  * a reduced `KeyValue`'s parser value has a type of `Value[string]`.

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
