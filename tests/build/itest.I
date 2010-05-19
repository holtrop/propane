
[tokens]

AND         and
OR          or
NOT         not
LPAREN      \(
RPAREN      \)
WS          \s+ %{
    cout << "Hi there WS!!!!!" << endl;
%}
EQUALS      =
IDENTIFIER  [a-zA-Z_][a-zA-Z_0-9]*

DEC_INT     [1-9]\d*\b
${
    uint64_t value;
$}
%{
    sscanf("%lld", matches[1].c_str(), &value);
%}

HEX_INT     0x([0-9a-fA-F]+)\b ${ uint64_t value; $} %{
    sscanf("%llx", matches[1].c_str(), &value);
%}

OCT_INT     0([0-7]*)\b

[rules]

Assignment := IDENTIFIER ASSIGN Expression

Expression := IDENTIFIER \
            | Assignment
