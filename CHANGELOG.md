## v2.0.0

### Improvements

- Log conflicting rules on reduce/reduce conflict (#31)
- Use 1-based row and column values for position values (#30)

### Fixes

- Fix named optional rules (#29)

### Upgrading

- Adjust all uses of p_position_t row and col values to expect 1-based instead
of 0-based values.

## v1.5.1

### Improvements

- Improve performance (#28)

## v1.5.0

### New Features

- Track start and end text positions for tokens and rules in AST node structures (#27)
- Add warnings for shift/reduce conflicts to log file (#25)
- Add -w command line switch to treat warnings as errors and output to stderr (#26)
- Add rule field aliases (#24)

### Improvements

- Show line numbers of rules on conflict (#23)

## v1.4.0

### New Features

- Allow user to specify AST node name prefix or suffix
- Allow specifying the start rule name
- Allow rule terms to be marked as optional

### Improvements

- Give a better error message when a referenced ptype has not been declared

## v1.3.0

### New Features

- Add AST generation (#22)

## v1.2.0

### New Features

- Allow one line user code blocks (#21)
- Add backslash escape codes (#19)
- Add API to access unexpected token found (#18)
- Add token_names API (#17)
- Add D example to user guide for p_context_init() (#16)
- Allow user termination from lexer code blocks (#15)

### Fixes

- Fix generator hang when state transition cycle is present (#20)

## v1.1.0

### New Features

- Add user parser terminations (#13)
- Document generated parser API in user guide (#14)

## v1.0.0

- Initial release
