use testparser::*;

fn main() {
    let mut context = p_context_new(b"identifier_123");
    assert_eq!(P_SUCCESS, p_parse(&mut context));
    println!("pass1");
    p_context_delete(context);
}
