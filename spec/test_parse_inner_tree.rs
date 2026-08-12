use testparser::*;

fn main() {
    let mut c = p_context_new(b"ab");
    assert_eq!(P_SUCCESS, p_parse_R1(&mut c));
    {
        let tree = p_result_R1(&c);
        assert!(tree.valid());
        assert!(tree.pToken1().valid());
        assert_eq!(TOKEN_a, tree.pToken1().token());
        assert!(tree.pToken2().valid());
        assert_eq!(TOKEN_b, tree.pToken2().token());
    }
    p_context_delete(c);

    let mut c = p_context_new(b"abb");
    assert_eq!(P_SUCCESS, p_parse_inner_R1(&mut c, &[TOKEN_b]));
    {
        let tree = p_result_R1(&c);
        assert!(tree.valid());
        assert_eq!(TOKEN_a, tree.pToken1().token());
        assert_eq!(1, tree.pToken1().position().row);
        assert_eq!(1, tree.pToken1().position().col);
        assert_eq!(TOKEN_b, tree.pToken2().token());
        assert_eq!(2, tree.pToken2().position().col);
        assert_eq!(1, tree.position().col);
        assert_eq!(2, tree.end_position().col);
    }
    let pos = p_position(&c);
    assert_eq!(3, pos.col);
    let mut ti = p_token_info_t::default();
    assert_eq!(P_SUCCESS, p_lex(&mut c, &mut ti));
    assert_eq!(TOKEN_b, ti.token);
    assert_eq!(3, ti.position.col);
    p_context_delete(c);
}
