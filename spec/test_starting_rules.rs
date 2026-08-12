use testparser::*;

fn main() {
    let mut c = p_context_new(b"bbbb");
    assert_eq!(P_SUCCESS, p_parse(&mut c));
    assert_eq!(8, p_result(&c));
    p_context_delete(c);

    let mut c = p_context_new(b"bbbb");
    assert_eq!(P_SUCCESS, p_parse_Bs(&mut c));
    assert_eq!(8, p_result_Bs(&c));
    p_context_delete(c);

    let mut c = p_context_new(b"c");
    assert_eq!(P_SUCCESS, p_parse_R(&mut c));
    assert_eq!(3, p_result_R(&c));
    p_context_delete(c);
}
