use testparser::*;

fn main() {
    let mut context = p_context_new(b"ab");
    assert_eq!(P_SUCCESS, p_parse(&mut context));

    assert_eq!(3, context.start_n_fields);
    assert_eq!(11, context.start_a_value);
    assert_eq!(11, context.a_value);
    assert_eq!(22, context.b_value);
    assert_eq!(TOKEN_b, context.b_token);
    assert_eq!(1, context.c_is_null);
    assert_eq!(1, context.c_field_is_null);
    assert_eq!(11, context.alias_a_value);
    assert_eq!(22, context.alias_b_value);

    {
        let start = p_result(&context);
        assert!(start.pA().valid());
        assert!(start.pB().valid());
        assert!(!start.pC().valid());
    }
    p_context_delete(context);
}
