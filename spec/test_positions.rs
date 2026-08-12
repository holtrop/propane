use testparser::*;

fn main() {
    let mut c = p_context_new(b"    Hello\n\n        4200\n");
    assert_eq!(P_SUCCESS, p_parse(&mut c));
    p_context_delete(c);

    println!();

    let mut c = p_context_new(b"\n tok2");
    assert_eq!(P_SUCCESS, p_parse(&mut c));
    p_context_delete(c);

    println!();

    let mut c = p_context_new(b"  tok1");
    assert_eq!(P_SUCCESS, p_parse(&mut c));
    p_context_delete(c);
}
