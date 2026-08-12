use testparser::*;

fn main() {
    let mut c = p_context_new(b"foo1\nbar2");
    assert_eq!(P_SUCCESS, p_parse(&mut c));
    p_context_delete(c);
}
