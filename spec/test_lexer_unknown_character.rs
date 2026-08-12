use testparser::*;

fn main() {
    let mut context = p_context_new(b"x");
    assert_eq!(P_UNEXPECTED_INPUT, p_parse(&mut context));
    p_context_delete(context);

    let mut context = p_context_new(b"123");
    assert_eq!(P_SUCCESS, p_parse(&mut context));
    assert_eq!(123, p_result(&context));
    p_context_delete(context);
}
