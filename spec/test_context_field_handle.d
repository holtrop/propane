import testparser;
import testutils;

int main()
{
    return 0;
}

unittest
{
    /* Enough tokens that the tree node array is reallocated during the parse. */
    string input;
    foreach (i; 0 .. 40)
    {
        input ~= "a";
    }

    p_context_t * context = p_context_new(input);
    assert_eq(P_SUCCESS, p_parse(context));

    /* The handle was stored in a context user field during the parse, before
     * the remaining nodes were created. It still refers to the same node. */
    assert_eq(1, context.have_first);
    assert(context.first_item.valid);
    Token token = context.first_item.pToken1;
    assert(token.valid);
    assert_eq(TOKEN_a, token.token);
    assert_eq(7, token.pvalue);

    /* The stored handle refers to the first Item, which starts at column 1. */
    assert_eq(1u, context.first_item.position.row);
    assert_eq(1u, context.first_item.position.col);

    p_context_delete(context);
}
