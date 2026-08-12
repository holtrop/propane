use testparser::*;

fn main() {
    let mut c = p_context_new(b"{}");
    assert_eq!(P_SUCCESS, p_parse(&mut c));
    assert_eq!(JSON_OBJECT, p_result(&c).id());
    p_context_delete(c);

    let mut c = p_context_new(b"[]");
    assert_eq!(P_SUCCESS, p_parse(&mut c));
    assert_eq!(JSON_ARRAY, p_result(&c).id());
    p_context_delete(c);

    let mut c = p_context_new(b"-45.6");
    assert_eq!(P_SUCCESS, p_parse(&mut c));
    assert_eq!(JSON_NUMBER, p_result(&c).id());
    assert_eq!(-45.6, p_result(&c).number());
    p_context_delete(c);

    let mut c = p_context_new(b"{\"hi\":true}");
    assert_eq!(P_SUCCESS, p_parse(&mut c));
    assert_eq!(JSON_OBJECT, p_result(&c).id());
    p_context_delete(c);

    let mut c = p_context_new(b"[1, 2, \"three\", [4, 5], {\"six\": 6}]");
    assert_eq!(P_SUCCESS, p_parse(&mut c));
    let v = p_result(&c);
    assert_eq!(JSON_ARRAY, v.id());
    assert_eq!(5, v.array_len());
    p_context_delete(c);
}
