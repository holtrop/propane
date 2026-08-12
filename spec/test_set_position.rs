use testparser::*;

fn main() {
    let mut ti = p_token_info_t::default();

    /* Baseline: default (1, 1). */
    let mut c = p_context_new(b"ab");
    let pos = p_position(&c);
    assert_eq!(1, pos.row);
    assert_eq!(1, pos.col);
    assert_eq!(P_SUCCESS, p_lex(&mut c, &mut ti));
    assert_eq!(TOKEN_a, ti.token);
    assert_eq!(1, ti.position.row);
    assert_eq!(1, ti.position.col);
    p_context_delete(c);

    /* p_set_position overrides the initial position. */
    let mut c = p_context_new(b"ab");
    p_set_position(&mut c, p_position_t { row: 5, col: 20 });
    let pos = p_position(&c);
    assert_eq!(5, pos.row);
    assert_eq!(20, pos.col);
    assert_eq!(P_SUCCESS, p_lex(&mut c, &mut ti));
    assert_eq!(TOKEN_a, ti.token);
    assert_eq!(5, ti.position.row);
    assert_eq!(20, ti.position.col);
    assert_eq!(P_SUCCESS, p_lex(&mut c, &mut ti));
    assert_eq!(TOKEN_b, ti.token);
    assert_eq!(5, ti.position.row);
    assert_eq!(21, ti.position.col);
    p_context_delete(c);

    /* Set position before a full parse. */
    let mut c = p_context_new(b"ab");
    p_set_position(&mut c, p_position_t { row: 3, col: 7 });
    assert_eq!(P_SUCCESS, p_parse_Start(&mut c));
    p_context_delete(c);

    /* Set position before a failing parse: error position is relative. */
    let mut c = p_context_new(b"aa");
    p_set_position(&mut c, p_position_t { row: 10, col: 2 });
    assert_eq!(P_UNEXPECTED_TOKEN, p_parse_Start(&mut c));
    let ep = p_position(&c);
    assert_eq!(10, ep.row);
    assert_eq!(3, ep.col);
    p_context_delete(c);

    /* p_set_input_index rewinds the byte cursor to re-read a section. */
    let mut c = p_context_new(b"ab");
    let start_index = p_input_index(&c);
    let start_position = p_position(&c);
    assert_eq!(0, start_index);
    assert_eq!(P_SUCCESS, p_lex(&mut c, &mut ti));
    assert_eq!(TOKEN_a, ti.token);
    assert_eq!(P_SUCCESS, p_lex(&mut c, &mut ti));
    assert_eq!(TOKEN_b, ti.token);
    assert_eq!(2, p_input_index(&c));
    p_set_input_index(&mut c, start_index);
    p_set_position(&mut c, start_position);
    assert_eq!(0, p_input_index(&c));
    assert_eq!(P_SUCCESS, p_lex(&mut c, &mut ti));
    assert_eq!(TOKEN_a, ti.token);
    assert_eq!(1, ti.position.row);
    assert_eq!(1, ti.position.col);
    p_context_delete(c);
}
