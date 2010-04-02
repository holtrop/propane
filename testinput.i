
[rules]

ASSIGN     := ":="
DASSIGN    := ":=="
IDENTIFIER := "[a-zA-Z_][a-zA-Z_0-9]*"

Assignment := IDENTIFIER ASSIGN Expression

Expression := IDENTIFIER
            | Assignment
