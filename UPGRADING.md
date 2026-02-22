## v4.0.0

### API Changes

- Replace any calls to `p_context_init()` with `p_context_new()`.
- Replace any references to the address of a statically allocated context
  structure with the pointer returned from `p_context_init()` (e.g. `&context`
  -> `context`).
- Add a call to `p_context_delete()` (for C or C++) after lexing/parsing to
  reclaim context memory.
- Rename `p_free_tree()` calls to `p_tree_delete()`.
- Change `free_token_node` statement calls from taking a function name argument
  to taking a user code block.

## v3.0.0

### Grammar Changes

- Rename `ast;` statement to `tree;`.
- Rename `ast_prefix;` statement to `tree_prefix;`.
- Rename `ast_suffix;` statement to `tree_suffix;`.
