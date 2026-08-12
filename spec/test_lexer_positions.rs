use testparser::*;

fn main() {
    let mut c = p_context_new(b"abc\n  defg hi\n!");
    let mut ti = p_token_info_t::default();

    assert_eq!(P_SUCCESS, p_lex(&mut c, &mut ti));
    assert_eq!(TOKEN_word, ti.token);
    assert_eq!(1, c.last_start.row);
    assert_eq!(1, c.last_start.col);
    assert_eq!(1, c.last_end.row);
    assert_eq!(3, c.last_end.col);
    assert_eq!(c.last_start.row, ti.position.row);
    assert_eq!(c.last_start.col, ti.position.col);
    assert_eq!(c.last_end.row, ti.end_position.row);
    assert_eq!(c.last_end.col, ti.end_position.col);

    assert_eq!(P_SUCCESS, p_lex(&mut c, &mut ti));
    assert_eq!(TOKEN_word, ti.token);
    assert_eq!(2, c.last_start.row);
    assert_eq!(3, c.last_start.col);
    assert_eq!(2, c.last_end.row);
    assert_eq!(6, c.last_end.col);

    assert_eq!(P_SUCCESS, p_lex(&mut c, &mut ti));
    assert_eq!(TOKEN_word, ti.token);
    assert_eq!(2, c.last_start.row);
    assert_eq!(8, c.last_start.col);
    assert_eq!(2, c.last_end.row);
    assert_eq!(9, c.last_end.col);

    assert_eq!(P_USER_TERMINATED, p_lex(&mut c, &mut ti));
    assert_eq!(42, p_user_terminate_code(&c));
    assert_eq!(3, p_position(&c).row);
    assert_eq!(1, p_position(&c).col);

    p_context_delete(c);
}
