use testparser::*;

fn eval(input: &[u8]) -> i64 {
    let mut c = p_context_new(input);
    assert_eq!(P_SUCCESS, p_parse(&mut c));
    let v = p_result(&c);
    p_context_delete(c);
    v
}

fn main() {
    assert_eq!(5, eval(b"2 + 3"));
    assert_eq!(3, eval(b"(1 + 2)"));
    assert_eq!(14, eval(b"2 + (3 + 4) + 5"));
    assert_eq!(37, eval(b"2 + (10 + (20 + 5))"));
    assert_eq!(15, eval(b"(1 + 2) + (3 + (4 + 5))"));
}
