use testparser::*;

fn main() {
    let mut context = p_context_new(b"hi");
    assert_eq!(P_SUCCESS, p_parse(&mut context));
    {
        let top = p_result(&context);
        assert!(top.pToken().valid());
        assert_eq!(TOKEN_hi, top.pToken().token());
    }
    p_context_delete(context);
}
