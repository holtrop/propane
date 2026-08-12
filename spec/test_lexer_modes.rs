use testparser::*;

fn main() {
    let mut context = p_context_new(b"abc \"a string\" def");
    assert_eq!(P_SUCCESS, p_parse(&mut context));
    println!("pass1");
    p_context_delete(context);

    let mut context = p_context_new(b"abc \"abc def\" def");
    assert_eq!(P_SUCCESS, p_parse(&mut context));
    println!("pass2");
    p_context_delete(context);
}
