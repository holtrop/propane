use testparser::*;

fn main() {
    let mut context = p_context_new(b"defghidef");
    assert_eq!(P_SUCCESS, p_parse(&mut context));
    p_context_delete(context);
}
