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
  * targets C, C++, or D language outputs
  * optionally supports automatic full parse tree generation
  * supports starting parsing from multiple start rules
  * tracks input text start and end positions for all matched tokens/rules
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
E3 -> E3 power E4 << $$ = pow($1, $3); >>
E4 -> integer << $$ = $1; >>
E4 -> lparen E1 rparen << $$ = $2; >>
```

Grammar files can contain comment lines beginning with `#` which are ignored.
White space in the grammar file is also ignored.

It is convention to use the extension `.propane` for the Propane grammar file,
however any file name is accepted by Propane.

This user guide follows the convention of beginning a token name with a
lowercase character and beginning a rule name with an uppercase character.

##> User Code Blocks

User code blocks begin following a "<<" token and end with a ">>" token found
at the end of a line.
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

#### C/C++

The lexer code block is passed the following arguments:

  * `match` - a pointer points to the text matched by the lexer pattern.
  * `match_length` - length of the matched text.

Example:

```
ptype long;

token integer /\d+/ <<
  long v = 0;
  for (size_t i = 0u; i < match_length; i++)
  {
    v *= 10;
    v += (match[i] - '0');
  }
  $$ = v;
>>
```

#### D

The lexer code block is passed the following arguments:

  * `match` - a slice containing the text matched by the lexer pattern.

```
ptype ulong;

token integer /\d+/ <<
  ulong v;
  foreach (c; match)
  {
    v *= 10;
    v += (c - '0');
  }
  $$ = v;
>>
```

Lexer code blocks appear following a `drop`, `token`, or pattern expression.
User code in a lexer code block will be executed when the lexer matches the
given pattern.
Assignment to the `$$` symbol will associate a parser value with the lexed
token.
This parser value can then be used later in a parser rule.

### Parser rule code blocks

Example:

```
E1 -> E1 plus E2 << $$ = $1 + $3; >>
```

Parser rule code blocks appear following a rule expression.
User code in a parser rule code block will be executed when the parser reduces
the given rule.
Assignment to the `$$` symbol will associate a parser value with the reduced
rule.
Parser values for the rules or tokens in the rule pattern can be accessed
positionally with tokens `$1`, `$2`, `$3`, etc...

Parser rule code blocks are not available in tree generation mode.
In tree generation mode, a full parse tree is automatically constructed in
memory for user code to traverse after parsing is complete.

### Context code blocks: the `context` statement

Propane uses a context structure for lexer and parser operations.
Custom fields may be added to the context structure by using the grammar
`context` statement.
This allows lexer pattern or parser rule code blocks to access user-defined
fields within the context structure.

Example:

```
context <<
    int mycontextval;
>>
```

Lexer user code blocks or parser user code blocks can access user-defined
context fields by using the `${context.<field>}` syntax.

C++ example:

```
context <<
    std::string comments;
>>
drop /#(.*)\n/ <<
    /* Accumulate comments before the next parser tree node. */
    ${context.comments} += std::string((const char *)match, match_length);
>>
```

If a pointer to any allocated memory is stored in a user-defined context field,
it is up to the user to free any memory when the program is finished using the
context structure.

##> Tree generation mode - the `tree` statement

To activate tree generation mode, place the `tree` statement in your grammar file:

```
tree;
```

It is recommended to place this statement early in the grammar.

In tree generation mode various aspects of propane's behavior are changed:

  * Only one `ptype` is allowed.
  * Parser user code blocks are not supported.
  * Structure types are generated to represent the parsed tokens and rules as
  defined in the grammar.
  * The parse result from `p_result()` points to a `Start` struct containing
  the entire parse tree for the input. If the user has changed the start rule
  with the `start` grammar statement, the name of the start struct will be
  given by the user-specified start rule instead of `Start`.

Example tree generation grammar:

```
tree;

ptype int;

token a << $$ = 11; >>
token b << $$ = 22; >>
token one /1/;
token two /2/;
token comma /,/ <<
  $$ = 42;
>>
token lparen /\(/;
token rparen /\)/;
drop /\s+/;

Start -> Items;

Items -> Item:item ItemsMore;
Items -> ;

ItemsMore -> comma Item:item ItemsMore;
ItemsMore -> ;

Item -> a;
Item -> b;
Item -> lparen Item:item rparen;
Item -> Dual;

Dual -> One Two;
Dual -> Two One;
One -> one;
Two -> two;
```

The following unit test describes the fields that will be present for an
example parse:

```
string input = "a, ((b)), b";
p_context_t context;
p_context_init(&context, input);
assert_eq(P_SUCCESS, p_parse(&context));
Start * start = p_result(&context);
assert(start.pItems1 !is null);
assert(start.pItems !is null);
Items * items = start.pItems;
assert(items.item !is null);
assert(items.item.pToken1 !is null);
assert_eq(TOKEN_a, items.item.pToken1.token);
assert_eq(11, items.item.pToken1.pvalue);
assert(items.pItemsMore !is null);
ItemsMore * itemsmore = items.pItemsMore;
assert(itemsmore.item !is null);
assert(itemsmore.item.item !is null);
assert(itemsmore.item.item.item !is null);
assert(itemsmore.item.item.item.pToken1 !is null);
assert_eq(TOKEN_b, itemsmore.item.item.item.pToken1.token);
assert_eq(22, itemsmore.item.item.item.pToken1.pvalue);
assert(itemsmore.pItemsMore !is null);
itemsmore = itemsmore.pItemsMore;
assert(itemsmore.item !is null);
assert(itemsmore.item.pToken1 !is null);
assert_eq(TOKEN_b, itemsmore.item.pToken1.token);
assert_eq(22, itemsmore.item.pToken1.pvalue);
assert(itemsmore.pItemsMore is null);
```

## `tree_prefix` and `tree_suffix` statements

In tree generation mode, structure types are defined and named based on the
rules in the grammar.
Additionally, a structure type called `Token` is generated to hold parsed
token information.

These structure names can be modified by using the `tree_prefix` or `tree_suffix`
statements in the grammar file.
The field names that point to instances of the structures are not affected by
the `tree_prefix` or `tree_suffix` values.

For example, if the following two lines were added to the example above:

```
tree_prefix ABC;
tree_suffix XYZ;
```

Then the types would be used as such instead:

```
string input = "a, ((b)), b";
p_context_t context;
p_context_init(&context, input);
assert_eq(P_SUCCESS, p_parse(&context));
ABCStartXYZ * start = p_result(&context);
assert(start.pItems1 !is null);
assert(start.pItems !is null);
ABCItemsXYZ * items = start.pItems;
assert(items.pItem !is null);
assert(items.pItem.pToken1 !is null);
assert_eq(TOKEN_a, items.pItem.pToken1.token);
assert_eq(11, items.pItem.pToken1.pvalue);
assert(items.pItemsMore !is null);
ABCItemsMoreXYZ * itemsmore = items.pItemsMore;
assert(itemsmore.pItem !is null);
assert(itemsmore.pItem.pItem !is null);
assert(itemsmore.pItem.pItem.pItem !is null);
assert(itemsmore.pItem.pItem.pItem.pToken1 !is null);
```

## Freeing user-allocated memory in token node `pvalue`: the `free_token_node` statement

If user lexer code block allocates memory to store in a token node's `pvalue`,
the `free_token_node` grammar statement can be used to specify the name of a
function which will be called during the `p_free_tree()` call to free the memory
associated with a token node.

Example:

```
<<
static void free_token(Token * token)
{
    free(token->pvalue);
}
>>
tree;
free_token_node free_token;
ptype int *;
token a <<
  $$ = (int *)malloc(sizeof(int));
  *$$ = 1;
>>
token b <<
  $$ = (int *)malloc(sizeof(int));
  *$$ = 2;
>>
Start -> a:a b:b;
```

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
token if << writeln("'if' keyword lexed"); >>
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
/foo+/ << writeln("saw a foo pattern"); >>
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
/#.*/
```

Regular expressions can include many special characters/sequences:

  * The `.` character matches any input character other than a newline.
  * The `*` character matches any number of the previous regex element.
  * The `+` character matches one or more of the previous regex element.
  * The `?` character matches 0 or 1 of the previous regex element.
  * The `[` character begins a character class.
  * The `(` character begins a matching group.
  * The `{` character begins a count qualifier.
  * The `\` character escapes the following character and changes its meaning:
    * The `\a` sequence matches an ASCII bell character (0x07).
    * The `\b` sequence matches an ASCII backspace character (0x08).
    * The `\d` sequence is shorthand for the `[0-9]` character class.
    * The `\D` sequence matches every code point not matched by `\d`.
    * The `\f` sequence matches an ASCII form feed character (0x0C).
    * The `\n` sequence matches an ASCII new line character (0x0A).
    * The `\r` sequence matches an ASCII carriage return character (0x0D).
    * The `\s` sequence is shorthand for the `[ \t\r\n\f\v]` character class.
    * The `\S` sequence matches every code point not matched by `\s`.
    * The `\t` sequence matches an ASCII tab character (0x09).
    * The `\v` sequence matches an ASCII vertical tab character (0x0B).
    * The `\w` sequence is shorthand for the `[a-zA-Z0-9_]` character class.
    * The `\W` sequence matches every code point not matched by `\w`.
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
string: /[^"]+/ << mystringvalue ~= match; >>
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

Multiple modes can be specified for a token or pattern or drop statement.
For example, if the grammar wanted to only recognize an identifier following
a `.` token and not other keywords, it could switch to an `identonly` mode
when matching a `.`
The `ident` token pattern will be matched in either the `default` or
`identonly` mode.

```
ptype char;
token abc;
token def;
default, identonly: token ident /[a-z]+/ <<
  $$ = match[0];
  $mode(default);
  return $token(ident);
>>
token dot /\./ <<
  $mode(identonly);
>>
default, identonly: drop /\s+/;
```

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

Object -> lbrace rbrace << $$ = new Value(); >>

Values (array) -> Value << $$ = [$1]; >>
Values -> Values comma Value << $$ = $1 ~ [$3]; >>

KeyValue (dict) -> string colon Value << $$ = [$1: $3]; >>
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

When tree generation mode is active, the `ptype` functionality works differently.
In this mode, only one `ptype` is used by the parser.
Lexer user code blocks may assign a parse value to the generated `Token` node
by assigning to `$$` within a lexer code block.
The type of the parse value `$$` is given by the global `ptype` type.

##> Specifying a parser rule - the rule statement

Rule statements create parser rules which define the grammar that will be
parsed by the generated parser.

Multiple rules with the same name can be specified.
Rules with the same name define a rule set for that name and act as
alternatives that the parser can accept when attempting to match a reference to
that rule.

The default start rule name is `Start`.
This can be changed with the `start` statement.
The grammar file must define a rule with the name of the start rule name which
will be used as the top-level starting rule that the parser attempts to reduce.

Rule statements are composed of the name of the rule, a `->` token, the fields
defining the rule pattern that must be matched, and a terminating semicolon or
user code block.

Example:

```
ptype ulong;
start Top;
token word /[a-z]+/ << $$ = match.length; >>
Top -> word << $$ = $1; >>
```

In the above example the `Top` rule is defined to match a single `word`
token.

Another example:

```
Start -> E1 << $$ = $1; >>
E1 -> E2 << $$ = $1; >>
E1 -> E1 plus E2 << $$ = $1 + $3; >>
E2 -> E3 << $$ = $1; >>
E2 -> E2 times E3 << $$ = $1 * $3; >>
E3 -> E4 << $$ = $1; >>
E3 -> E3 power E4 << $$ = pow($1, $3); >>
E4 -> integer << $$ = $1; >>
E4 -> lparen E1 rparen << $$ = $2; >>
```

This example uses the default start rule name of `Start`.

A parser rule has zero or more fields on the right side of its definition.
Each of these fields is either a token name or a rule name.
A field can be immediately followed by a `?` character to signify that it is
optional.
A field can optionally be followed by a `:` and then a field alias name.
If present, the field alias name is used to refer to the field value in user
code blocks, or if tree generation mode is active, the field alias name is used
as the field name in the generated tree node structure.
An optional and named field must use the format `field?:name`.
Example:

```
token public;
token private;
token int;
token ident /[a-zA-Z_][a-zA-Z_0-9]*/;
token semicolon /;/;
IntegerDeclaration -> Visibility?:visibility int ident:name semicolon;
Visibility -> public;
Visibility -> private;
```

In a parser rule code block, parser values for the right side fields are
accessible as `$1` for the first field's parser value, `$2` for the second
field's parser value, etc...
For the `IntegerDeclaration` rule, the first field value can also be referred to as `${visibility}` and the third field value can also be referred
to as `${name}`.
The `$$` symbol accesses the output parser value for this rule.
The above examples demonstrate how the parser values for the rule components
can be used to produce the parser value for the accepted rule.

Parser rule code blocks are not allowed and not used when tree generation mode
is active.

##> Specifying the parser start rule name - the `start` statement

The start rule can be changed from the default of `Start` by using the `start`
statement.
Example:

```
start MyStartRule;
```

Multiple start rules can be specified, either with multiple `start` statements
or one `start` statement listing multiple start rules.
Example:

```
start Module ModuleItem Statement Expression;
```

When multiple start rules are specified, multiple `p_parse_*()` functions,
`p_result_*()`, and `p_free_tree_*()` functions (in tree mode) are generated.
A default `p_parse()`, `p_result()`, `p_free_tree()` are generated corresponding
to the first start rule.
Additionally, each start rule causes the generation of another version of each
of these functions, for example `p_parse_Statement()`, `p_result_Statement()`,
and `p_free_tree_Statement()`.

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
  * Determine whether parsing should stop and instead be retried using a different parser version.

To terminate parsing from a lexer or parser user code block, use the
`$terminate(code)` function, passing an integer expression argument.
For example:

```
NewExpression -> new Expression << $terminate(42); >>
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

Result codes are returned by the API functions `p_decode_code_point()`, `p_lex()`, and `p_parse()`.

##> Types

### `p_code_point_t`

The `p_code_point_t` type is aliased to a 32-bit unsigned integer.
It is used to store decoded code points from the input text and perform
lexing based on the grammar's lexer patterns.

### `p_context_t`

Propane defines a `p_context_t` structure type.
The structure is intended to be used opaquely and stores information related to
the state of the lexer and parser.
Integrating code must define an instance of the `p_context_t` structure.
A pointer to this instance is passed to the generated functions.

### `p_position_t`

The `p_position_t` structure contains two fields: `row` and `col`.
These fields contain the 1-based row and column describing a parser position.

For D targets, the `p_position_t` structure can be checked for validity by
querying the `valid` property.

For C targets, the `p_position_t` structure can be checked for validity by
calling `p_position_valid(pos)` where `pos` is a `p_position_t` structure
instance.

### `p_token_info_t`

The `p_token_info_t` structure contains the following fields:

* `position` (`p_position_t`) holds the text position of the first code point in the token.
* `end_position` (`p_position_t`) holds the text position of the last code point in the token.
* `length` (`size_t`) holds the number of input bytes used by the token.
* `token` (`p_token_t`) holds the token ID of the lexed token
* `pvalue` (`p_value_t`) holds the parser value associated with the token.

### Tree Node Types

If tree generation mode is enabled, a structure type for each rule will be
generated.
The name of the structure type is given by the name of the rule.
Additionally a structure type called `Token` is generated to represent a
tree node which refers to a raw parser token rather than a composite rule.

#### Tree Node Fields

All tree nodes have a `position` field specifying the text position of the
beginning of the matched token or rule, and an `end_position` field specifying
the text position of the end of the matched token or rule.
Each of these fields are instances of the `p_position_t` structure.

A `Token` node will always have a valid `position` and `end_position`.
A rule node may not have valid positions if the rule allows for an empty match.
In this case the `position` structure should be checked for validity before
using it.
For C targets this can be accomplished with
`if (p_position_valid(node->position))` and for D targets this can be
accomplished with `if (node.position.valid)`.

A `Token` node has the following additional fields:

  * `token` which specifies which token was parsed (one of `TOKEN_*`)
  * `pvalue` which specifies the parser value for the token. If a lexer user
  code block assigned to `$$`, the assigned value will be stored here.

Tree node structures for rules contain generated fields based on the
right hand side components specified for all rules of a given name.

In this example:

```
Start -> Items;

Items -> Item ItemsMore;
Items -> ;
```

The `Start` structure will have a field called `pItems` and another field of
the same name but with a positional suffix (`pItems1`) which both point to the
parsed `Items` node.
Their value will be null if the parsed `Items` rule was empty.

The `Items` structure will have fields:

  * `pItem` and `pItem1` which point to the parsed `Item` structure.
  * `pItemsMore` and `pItemsMore2` which point to the parsed `ItemsMore` structure.

If a rule can be empty (for example in the second `Items` rule above), then
an instance of a pointer to that rule's generated tree node will be null if the
parser matches the empty rule pattern.

The non-positional tree node field pointer will not be generated if there are
multiple positions in which an instance of the node it points to could be
present.
For example, in the below rules:

```
Dual -> One Two;
Dual -> Two One;
```

The generated `Dual` structure will contain `pOne1`, `pTwo2`, `pTwo1`, and
`pOne2` fields.
However, a `pOne` field and `pTwo` field will not be generated since it would
be ambiguous which one was matched.

If the first rule is matched, then `pOne1` and `pTwo2` will be non-null while
`pTwo1` and `pOne2` will be null.
If the second rule is matched instead, then the opposite would be the case.

If a field alias is present in a rule definition, an additional field will be
generated in the tree node with the field alias name.
For example:

```
Exp -> Exp:left plus ExpB:right;
```

In the generated `Exp` structure, the fields `pExp`, `pExp1`, and `left` will
all point to the same child node (an instance of the `Exp` structure), and the
fields `pExpB`, `pExpB3`, and `right` will all point to the same child node
(an instance of the `ExpB` structure).

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

### `p_lex`

The `p_lex()` function is the main entry point to the lexer.
It is normally called automatically by the generated parser to retrieve the
next input token for the parser and does not need to be called by the user.
However, the user may initialize a context and call `p_lex()` to use the
generated lexer in a standalone mode.

Example:

```
p_context_t context;
p_context_init(&context, input, input_length);
p_token_info_t token_info;
size_t result = p_lex(&context, &token_info);
switch (result)
{
case P_DECODE_ERROR:
    /* UTF-8 decode error */
    break;
case P_UNEXPECTED_INPUT:
    /* Input text does not match any lexer pattern. */
    break;
case P_USER_TERMINATED:
    /* Lexer user code block requested to terminate the lexer. */
    break;
case P_SUCCESS:
    /*
     * token_info.position holds the text position of the first code point in the token.
     * token_info.end_position holds the text position of the last code point in the token.
     * token_info.length holds the number of input bytes used by the token.
     * token_info.token holds the token ID of the lexed token
     * token_info.pvalue holds the parser value associated with the token.
     */
    break;
}
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

When multiple start rules are specified, a separate parse function is generated
for each which starts parsing at the given rule.
For example, if `Statement` is specified as a start rule:

```
size_t result = p_parse_Statement(&context);
```

In this case, the parser will start parsing with the `Statement` rule.

### `p_position_valid`

The `p_position_valid()` function is only generated for C targets.
it is used to determine whether or not a `p_position_t` structure is valid.

Example:

```
if (p_position_valid(node->position))
{
    ....
}
```

For D targets, rather than using `p_position_valid()`, the `valid` property
function of the `p_position_t` structure can be queried
(e.g. `if (node.position.valid)`).

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

If tree generation mode is active, then the `p_result()` function returns a
`Start *` pointing to the `Start` tree node structure.

When multiple start rules are specified, a separate result function is generated
for each which returns the parse result for the corresponding rule.
For example, if `Statement` is specified as a start rule:

```
p_context_t context;
p_context_init(&context, input, input_length);
size_t result = p_parse(&context);
if (p_parse_Statement(&context) == P_SUCCESS)
{
    result = p_result_Statement(&context);
}
```

In this case, the parser will start parsing with the `Statement` rule and the
parse result from the `Statement` rule will be returned.

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

### `p_decode_code_point`

The `p_decode_code_point()` function can be used to decode code points from a
UTF-8 string.
It does not require a lexer/parser context structure and can be used as a
standalone UTF-8 decoder or from within a lexer or parser user code block.

D Example:

```
size_t result;
p_code_point_t code_point;
ubyte code_point_length;

result = p_decode_code_point("\xf0\x9f\xa7\xa1", &code_point, &code_point_length);
assert(result == P_SUCCESS);
assert(code_point == 0x1F9E1u);
assert(code_point_length == 4u);
```

### `p_free_tree`

The `p_free_tree()` function can be used to free the memory used by the tree.
It should be passed the same value that is returned by `p_result()`.

The `p_free_tree()` function is only available for C/C++ output targets.

Note that if any lexer user code block allocates memory to store in a token's
`pvalue`, in order to properly free this memory a `free_token_node` function
should be specified in the grammar file.
If specified, the `free_token_node` function will be called during the
`p_free_tree()` process to allow user code to free any memory associated with
a token node's `pvalue`.

When multiple start rules are specified, a separate `p_free_tree` function is
generated for each which frees the tree resulting from parsing the given rule.
For example, if `Statement` is specified as a start rule:

```
p_free_tree_Statement(statement_tree);
```

In this case, Propane will free a `Statement` tree structure returned by the
`p_parse_Statement(&context)` function.

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
