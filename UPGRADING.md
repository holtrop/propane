## v5.0.0

The generated API for tree generation mode (`tree;`) has been changed
significantly for this version.
The lexer/parser value APIs for non-tree grammars are unchanged.

### Tree memory management

- Remove all calls to `p_tree_delete()` / `p_tree_delete_XXX()`. Tree nodes now
  live in the parser context and are freed by `p_context_delete()`.
- Tree node handles (returned by `p_result()` and the field accessors) are only
  valid while the context is alive. Do not use them after `p_context_delete()`.

### Tree node field access

Tree nodes are now referenced by handle values instead of pointers, and field
access differs per target language:

- C: replace `node->field` with the accessor function `p_TYPE_field(node)`, or
  use the tree walk macro `p_tree_walk_TYPE(node, field1, field2, ...)`. Replace
  `x != NULL` / `x == NULL` node checks with `p_node_valid(x)` /
  `!p_node_valid(x)`. Read positions with `p_node_position(node)` /
  `p_node_end_position(node)`, token payload with `p_TYPE_token(node)` /
  `p_TYPE_pvalue(node)` or `p_node_data(node)->field`, and compare node identity
  with `p_node_id(a) == p_node_id(b)`.
- C++: replace `node->field` with the handle method `node.field()`. Use
  `node.valid()`, `node.position()`, `node.token()`, `node.pvalue()`, and
  `node.data()->field` for user token fields. (The C-style functions and macros
  above are also available.)
- D: replace pointer declarations (`Start * s`) with value handles (`Start s`)
  and replace `x !is null` / `x is null` with `x.valid` / `!x.valid`. Field
  access syntax (`node.field.field`) is otherwise unchanged.

### Tree-mode parser rule user code

In tree generation mode `$$` and `$1`, `$2`, ... now expand to node handles.
Reference child fields through the target-language accessors above (for example
`$$->pA->pToken1->pvalue` becomes `p_tree_walk_Start($$, pA, pToken1, pvalue)`
in C, `$$.pA().pToken1().pvalue()` in C++, and `$$.pA.pToken1.pvalue` in D).

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
