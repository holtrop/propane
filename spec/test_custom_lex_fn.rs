use testparser::*;

fn main() {
    let mut c = p_context_new(b"cbacba");
    assert_eq!(P_SUCCESS, p_parse(&mut c));
    assert_eq!(0x932187932187, p_result(&c));
    p_context_delete(c);
}
