use testparser::*;

fn main() {
    let mut context = p_context_new(b"x");
    assert_eq!(P_SUCCESS, p_parse(&mut context));
    assert_eq!(1, p_result(&context));
    p_context_delete(context);

    let mut context = p_context_new(b"fabulous");
    assert_eq!(P_SUCCESS, p_parse(&mut context));
    assert_eq!(8, p_result(&context));
    p_context_delete(context);
}
