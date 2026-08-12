use testparser::*;

fn main() {
    let mut context = p_context_new(b"\na\nb\nc");
    assert_eq!(P_SUCCESS, p_parse(&mut context));
    {
        let start = p_result(&context);
        assert_eq!(TOKEN_a, start.first().pToken().token());
        assert_eq!(TOKEN_b, start.second().pToken().token());
        assert_eq!(TOKEN_c, start.third().pToken().token());
    }
    p_context_delete(context);
}
