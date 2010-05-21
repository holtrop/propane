
[tokens]

AND         and
OR          or
NOT         not
LPAREN      \(
RPAREN      \)
WS          \s+
EQUALS      = %{ cout << "Saw '='" << endl; %}
IDENTIFIER  [a-zA-Z_][a-zA-Z_0-9]* %{
    cout << "Identify: '" << matches[0] << "'" << endl;
%}

DEC_INT     [1-9]\d*\b
${
    uint64_t value;
$}
%{
    sscanf("%lld", matches[1].c_str(), &value);
    cout << "value: " << value << endl;
%}

HEX_INT     0x([0-9a-fA-F]+)\b ${ uint64_t value; $} %{
    sscanf("%llx", matches[1].c_str(), &value);
    cout << "value: " << value << endl;
%}

OCT_INT     0([0-7]*)\b
BIN_INT     0b([01]+)\b

[rules]

Assignment := IDENTIFIER ASSIGN Expression

Expression := IDENTIFIER \
            | Assignment
