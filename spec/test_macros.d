import testparser;
import testutils;

size_t n_tokens;
p_token_info_t[10] token_infos;

// Capture the macro body tokens (everything up to the closing '}') into
// token_infos[]. Called from mylexfn() right after the definition's '{' has
// been lexed, so the input cursor is positioned at the first body token.
void capture_macro_body(p_context_t * context)
{
    n_tokens = 0u;
    for (;;)
    {
        size_t result = p_lex(context, &token_infos[n_tokens]);
        assert(result == P_SUCCESS);
        if (token_infos[n_tokens].token == TOKEN_rbrace)
        {
            break;
        }
        n_tokens++;
        assert(n_tokens < token_infos.length);
    }
}

size_t mylexfn(p_context_t * context, p_token_info_t * out_token_info)
{
    static bool defining;
    static bool expanding;
    static size_t expand_i;

    for (;;)
    {
        if (expanding)
        {
            size_t ei = expand_i++;
            if (expand_i >= n_tokens)
            {
                expanding = false;
            }
            *out_token_info = token_infos[ei];
            return P_SUCCESS;
        }

        size_t lex_result = p_lex(context, out_token_info);
        if (lex_result != P_SUCCESS)
        {
            return lex_result;
        }

        switch (out_token_info.token)
        {
        case TOKEN_macro:
            // Start of a macro definition: "macro macroname { ... }".
            defining = true;
            break;
        case TOKEN_macroname:
            if (!defining)
            {
                // Use of a macro: replay its captured body tokens instead of
                // returning the macroname to the parser.
                expanding = true;
                expand_i = 0u;
                continue;
            }
            // Definition name: pass through and keep waiting for '{'.
            break;
        case TOKEN_lbrace:
            if (defining)
            {
                // Consume and store the macro body now, before the parser gets
                // a chance to read its lookahead token (which would otherwise
                // swallow the first body token).
                capture_macro_body(context);
                defining = false;
            }
            break;
        default:
            defining = false;
            break;
        }
        return lex_result;
    }
}

size_t n_nums;
int[10] nums;

void record(int v)
{
    nums[n_nums++] = v;
}

int main()
{
    return 0;
}

unittest
{
    string input =
        "macro @m { 23 + 200 }\n" ~
        "66 + 100\n" ~
        "@m\n" ~
        "33 + 55\n" ~
        "@m\n";
    p_context_t * context = p_context_new(input);
    assert(p_parse(context) == P_SUCCESS);
    p_context_delete(context);

    assert(n_nums == 4);
    assert(nums[0] == 166);
    assert(nums[1] == 223);
    assert(nums[2] == 88);
    assert(nums[3] == 223);
}
