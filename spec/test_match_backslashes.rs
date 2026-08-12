use testparser::*;

fn main() {
    let mut c = p_context_new(b"\x07\x08\t\n\x0b\x0c\rt");
    assert_eq!(P_SUCCESS, p_parse(&mut c));
    p_context_delete(c);
}
