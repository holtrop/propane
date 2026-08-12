use testparser::*;

fn main() {
    let mut c = p_context_new(b"a 42");
    assert_eq!(P_SUCCESS, p_parse(&mut c));
    p_context_delete(c);

    let mut c = p_context_new(b"a\n123\na  a");
    assert_eq!(P_UNEXPECTED_TOKEN, p_parse(&mut c));
    assert_eq!(3, p_position(&c).row);
    assert_eq!(4, p_position(&c).col);
    assert_eq!(TOKEN_a, p_token(&c));
    p_context_delete(c);

    let mut c = p_context_new(b"12");
    assert_eq!(P_UNEXPECTED_TOKEN, p_parse(&mut c));
    assert_eq!(1, p_position(&c).row);
    assert_eq!(1, p_position(&c).col);
    assert_eq!(TOKEN_num, p_token(&c));
    p_context_delete(c);

    let mut c = p_context_new(b"a 12\n\nab");
    assert_eq!(P_UNEXPECTED_INPUT, p_parse(&mut c));
    assert_eq!(3, p_position(&c).row);
    assert_eq!(2, p_position(&c).col);
    p_context_delete(c);

    let mut c = p_context_new(b"a 12\n\na\n\n77\na   \xAA");
    assert_eq!(P_DECODE_ERROR, p_parse(&mut c));
    assert_eq!(6, p_position(&c).row);
    assert_eq!(5, p_position(&c).col);
    assert_eq!("a", p_token_names[TOKEN_a as usize]);
    assert_eq!("num", p_token_names[TOKEN_num as usize]);
    p_context_delete(c);
}
