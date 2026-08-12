use testparser::*;

fn main() {
    let mut context = p_context_new(b"a");
    assert_eq!(P_UNEXPECTED_TOKEN, p_parse(&mut context));
    assert_eq!(1, p_position(&context).row);
    assert_eq!(2, p_position(&context).col);
    assert_eq!(TOKEN___EOF, p_token(&context));
    p_context_delete(context);

    let mut context = p_context_new(b"a b");
    assert_eq!(P_SUCCESS, p_parse(&mut context));
    p_context_delete(context);

    let mut context = p_context_new(b"bb");
    assert_eq!(P_SUCCESS, p_parse(&mut context));
    p_context_delete(context);
}
