
[tokens]

AND         and
OR          or
NOT         not
LPAREN      \(
RPAREN      \)
WS          \s+
EQUALS      =
IDENTIFIER  [a-zA-Z_][a-zA-Z_0-9]*

[rules]

Assignment := IDENTIFIER ASSIGN Expression

Expression := IDENTIFIER \
            | Assignment
