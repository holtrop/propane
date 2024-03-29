${remove}
WARNING: This user guide is meant to be preprocessed and rendered by a custom
script.
The markdown source file is not intended to be viewed directly and will not
include all intended content.
${/remove}

#> Overview

Propane is a LALR Parser Generator (LPG) which:

  * accepts LR(0), SLR, and LALR grammars
  * generates a built-in lexer to tokenize input
  * supports UTF-8 lexer inputs
  * generates a table-driven shift/reduce parser to parse input in linear time
  * targets C or D language outputs
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

# Parser values are unsigned integers.
ptype ulong;

# A few basic arithmetic operators.
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
# Drop whitespace.
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

Grammar files can contain comment lines beginning with `#` which are ignored.
White space in the grammar file is also ignored.

It is convention to use the extension `.propane` for the Propane grammar file,
however any file name is accepted by Propane.

This user guide follows the convention of beginning a token name with a
lowercase character and beginning a rule name with an uppercase character.

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

Lexer code blocks appear following a `token` or pattern expression.
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

##> Specifying tokens - the `token` statement

The `token` statement allows defining a lexer token and a pattern to match that
token.
The name of the token must be specified immediately following the `token`
keyword.
A regular expression pattern may optionally follow the token name.
If a regular expression pattern is not specified, the name of the token is
taken to be the pattern.
See also: ${#Regular expression syntax}.

Example:

```
token for;
```

In this example, the token name is `for` and the pattern to match it is
`/for/`.

Example:

```
token lbrace /\{/;
```

In this example, the token name is `lbrace` and a single left curly brace will
match it.

The `token` statement can also include a user code block.
The user code block will be executed whenever the token is matched by the
lexer.

Example:

```
token if <<
  writeln("'if' keyword lexed");
>>
```

The `token` statement is actually a shortcut statement for a combination of a
`tokenid` statement and a pattern statement.
To define a lexer token without an associated pattern to match it, use a
`tokenid` statement.
To define a lexer pattern that may or may not result in a matched token, use
a pattern statement.

##> Defining tokens without a matching pattern - the `tokenid` statement

The `tokenid` statement can be used to define a token without associating it
with a lexer pattern that matches it.

Example:

```
tokenid string;
```

The `tokenid` statement can be useful when defining a token that may optionally
be returned by user code associated with a pattern.

It is also useful when lexer modes and multiple lexer patterns are required to
build up a full token.
A common example is parsing a string.
See the ${#Lexer modes} chapter for more information.

##> Specifying a lexer pattern - the pattern statement

A pattern statement is used to define a lexer pattern that can execute user
code but may not result in a matched token.

Example:

```
/foo+/ <<
  writeln("saw a foo pattern");
>>
```

This can be especially useful with ${#Lexer modes}.

See also ${#Regular expression syntax}.

##> Ignoring input sections - the `drop` statement

A `drop` statement can be used to specify a lexer pattern that when matched
should result in the matched input being dropped and lexing continuing after
the matched input.

A common use for a `drop` statement would be to ignore whitespace sequences in
the user input.

Example:

```
drop /\s+/;
```

See also ${#Regular expression syntax}.

##> Regular expression syntax

A regular expression ("regex") is used to define lexer patterns in `token`,
pattern, and `drop` statements.
A regular expression begins and ends with a `/` character.

Example:

```
/#.*$/
```

Regular expressions can include many special characters:

  * The `.` character matches any input character other than a newline.
  * The `*` character matches any number of the previous regex element.
  * The `+` character matches one or more of the previous regex element.
  * The `?` character matches 0 or 1 of the previous regex element.
  * The `[` character begins a character class.
  * The `(` character begins a matching group.
  * The `{` character begins a count qualifier.
  * The `\` character escapes the following character and changes its meaning:
    * The `\d` sequence matches any character `0` through `9`.
    * The `\s` sequence matches a space, horizontal tab `\t`, carriage return
    `\r`, a form feed `\f`, or a vertical tab `\v` character.
    * Any other character matches itself.
  * The `|` character creates an alternate match.

Any other character just matches itself in the input stream.

A character class consists of a list of character alternates or character
ranges that can be matched by the character class.
For example `[a-zA-Z_]` matches any lowercase character between `a` and `z` or
any uppercase character between `A` and `Z` or the underscore `_` character.
Character classes can also be negative character classes if the first character
after the `[` is a `^` character.
In this case, the set of characters matched by the character class is the
inverse of what it otherwise would have been.
For example, `[^0-9]` matches any character other than 0 through 9.

A matching group can be used to override the pattern sequence that multiplicity
specifiers apply to.
For example, the pattern `/foo+/` matches "foo" or "foooo", while the pattern
`/(foo)+/` matches "foo" or "foofoofoo", but not "foooo".

A count qualifier in curly braces can be used to restrict the number of matches
of the preceding atom to an explicit minimum and maximum range.
For example, the pattern `\d{3}` matches exactly 3 digits 0-9.
Both a minimum and maximum multiplicity count can be specified and separated by
a comma.
For example, `/a{1,5}/` matches between 1 and 5 `a` characters.
Either the minimum or maximum count can be omitted to omit the corresponding
restriction in the number of matches allowed.

An alternate match is created with the `|` character.
For example, the pattern `/foo|bar/` matches either the sequence "foo" or the
sequence "bar".

##> Lexer modes

Lexer modes can be used to change the set of patterns that are matched by the
lexer.
A common use for lexer modes is to match strings.

Example:

```
<<
string mystringvalue;
>>

tokenid str;

# String processing
/"/ <<
  mystringvalue = "";
  $mode(string);
>>
string: /[^"]+/ <<
  mystringvalue += match;
>>
string: /"/ <<
  $mode(default);
  return $token(str);
>>
```

A lexer mode is defined by placing the name before a colon (`:`) character that
precedes a token or pattern statement.
The token or pattern statement is restricted to only applying if the named mode
is active.

By default, the active lexer mode is named `default`.
A `$mode()` call within a lexer code block can be used to change lexer modes.

In the above example, when the lexer in the default mode sees a doublequote
(`"`) character, the lexer code block will clear the `mystringvalue` variable
and will set the lexer mode to `string`.
When the lexer begins looking for patterns to match against the input, it will
now look only for patterns tagged for the `string` lexer mode.
Any non-`"` character will be appended to the `mystringvalue` string.
A `"` character will end the `string` lexer mode and return to the `default`
lexer mode.
It also returns the `str` token now that the token is complete.

Note that the token name `str` above could have been `string` instead - the
namespace for token names is distinct from the namespace for lexer modes.

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

##> Specifying a parser rule - the rule statement

Rule statements create parser rules which define the grammar that will be
parsed by the generated parser.

Multiple rules with the same name can be specified.
Rules with the same name define a rule set for that name and act as
alternatives that the parser can accept when attempting to match a reference to
that rule.

The grammar file must define a rule with the name `Start` which will be used as
the top-level starting rule that the parser attempts to reduce.

Example:

```
ptype ulong;
token word /[a-z]+/ <<
  $$ = match.length;
>>
Start -> word <<
  $$ = $1;
>>
```

In the above example the `Start` rule is defined to match a single `word`
token.

Example:

```
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

A parser rule has zero or more terms on the right side of its definition.
Each of these terms is either a token name or a rule name.

In a parser rule code block, parser values for the right side terms are
accessible as `$1` for the first term's parser value, `$2` for the second
term's parser value, etc...
The `$$` symbol accesses the output parser value for this rule.
The above examples demonstrate how the parser values for the rule components
can be used to produce the parser value for the accepted rule.

##> Specifying the parser module name - the `module` statement

The `module` statement can be used to specify the module name for a generated
D module.

```
module proj.parser;
```

If a module statement is not present, then the generated D module will not
contain a module statement and the default module name will be used.

##> Specifying the generated API prefix - the `prefix` statement

By default the public API (types, constants, and functions) of the generated
lexer and parser uses a prefix of `p_`.

This prefix can be changed with the `prefix` statement.

Example:

```
prefix myparser_;
```

With a parser generated with this `prefix` statement, instead of calling
`p_context_init()` you would call `myparser_context_init()`.

The `prefix` statement can be optionally used if you would like to change the
prefix used by your generated lexer and parser to something other than the
default.

It can also be used when generating multiple lexers/parsers to be used in the
same program to avoid symbol collisions.

##> User termination of the lexer or parser

Propane supports allowing lexer or parser user code blocks to terminate
execution of the parser.
Some example uses of this functionality could be to:

  * Detect integer overflow when lexing an integer literal constant.
  * Detect and report an error as soon as possible during parsing before continuing to parse any more of the input.
  * Determine whether parsing should stop and instead be performed using a different parser version.

To terminate parsing from a lexer or parser user code block, use the
`$terminate(code)` function, passing an integer expression argument.
For example:

```
NewExpression -> new Expression <<
  $terminate(42);
>>
```

The value passed to the `$terminate()` function is known as the "user terminate
code".
If the parser returns a `P_USER_TERMINATED` result code, then the user
terminate code can be accessed using the `p_user_terminate_code()` API
function.

#> Propane generated API

By default, Propane uses a prefix of `p_` when generating a lexer/parser.
This prefix is used for all publicly declared types and functions.
The uppercase version of the prefix is used for all constant values.

This section documents the generated API using the default `p_` or `P_` names.

##> Constants

Propane generates the following result code constants:

* `P_SUCCESS`: A successful decode/lex/parse operation has taken place.
* `P_DECODE_ERROR`: An error occurred when decoding UTF-8 input.
* `P_UNEXPECTED_INPUT`: Input was received by the lexer that does not match any lexer pattern.
* `P_UNEXPECTED_TOKEN`: A token was seen in a location that does not match any parser rule.
* `P_DROP`: The lexer matched a drop pattern.
* `P_EOF`: The lexer reached the end of the input string.
* `P_USER_TERMINATED`: A parser user code block has requested to terminate the parser.

Result codes are returned by the functions `p_decode_input()`, `p_lex()`, and `p_parse()`.

##> Types

### `p_context_t`

Propane defines a `p_context_t` structure type.
The structure is intended to be used opaquely and stores information related to
the state of the lexer and parser.
Integrating code must define an instance of the `p_context_t` structure.
A pointer to this instance is passed to the generated functions.

### `p_position_t`

The `p_position_t` structure contains two fields `row` and `col`.
These fields contain the 0-based row and column describing a parser position.

##> Functions

### `p_context_init`

The `p_context_init()` function must be called to initialize the context
structure.
The input to be used for lexing/parsing is passed in when initializing the
context structure.

C example:

```
p_context_t context;
p_context_init(&context, input, input_length);
```

D example:

```
p_context_t context;
p_context_init(&context, input);
```

### `p_parse`

The `p_parse()` function is the main entry point to the parser.
It must be passed a pointer to an initialized context structure.

Example:

```
p_context_t context;
p_context_init(&context, input, input_length);
size_t result = p_parse(&context);
```

### `p_result`

The `p_result()` function can be used to retrieve the final parse value after
`p_parse()` returns a `P_SUCCESS` value.

Example:

```
p_context_t context;
p_context_init(&context, input, input_length);
size_t result = p_parse(&context);
if (p_parse(&context) == P_SUCCESS)
{
    result = p_result(&context);
}
```

### `p_position`

The `p_position()` function can be used to retrieve the parser position where
an error occurred.

Example:

```
p_context_t context;
p_context_init(&context, input, input_length);
size_t result = p_parse(&context);
if (p_parse(&context) == P_UNEXPECTED_TOKEN)
{
    p_position_t error_position = p_position(&context);
    fprintf(stderr, "Error: unexpected token at row %u column %u\n",
        error_position.row + 1, error_position.col + 1);
}
```

### `p_user_terminate_code`

The `p_user_terminate_code()` function can be used to retrieve the user
terminate code after `p_parse()` returns a `P_USER_TERMINATED` value.
User terminate codes are arbitrary values that can be defined by the user to
be returned when the user requests to terminate parsing.
They have no particular meaning to Propane.

Example:

```
if (p_parse(&context) == P_USER_TERMINATED)
{
    size_t user_terminate_code = p_user_terminate_code(&context);
}
```

### `p_token`

The `p_token()` function can be used to retrieve the current parse token.
This is useful after `p_parse()` returns a `P_UNEXPECTED_TOKEN` value.
terminate code after `p_parse()` returns a `P_USER_TERMINATED` value to
indicate what token the parser was not expecting.

Example:

```
if (p_parse(&context) == P_UNEXPECTED_TOKEN)
{
    p_token_t unexpected_token = p_token(&context);
}
```

##> Data

### `p_token_names`

The `p_token_names` array contains the grammar-specified token names.
It is indexed by the token ID.

C example:

```
p_context_t context;
p_context_init(&context, input, input_length);
size_t result = p_parse(&context);
if (p_parse(&context) == P_UNEXPECTED_TOKEN)
{
    p_position_t error_position = p_position(&context);
    fprintf(stderr, "Error: unexpected token `%s' at row %u column %u\n",
        p_token_names[context.token],
        error_position.row + 1, error_position.col + 1);
}
```

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
