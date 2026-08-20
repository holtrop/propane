use testparser::*;
use std::sync::atomic::Ordering;

fn main() {
    let mut context = p_context_new(b"ab");
    assert_eq!(P_SUCCESS, p_parse(&mut context));
    let start = p_result(&context);
    assert!(start.a().valid());
    assert_eq!(1, unsafe { *start.a().pvalue() });
    assert!(start.b().valid());
    assert_eq!(2, unsafe { *start.b().pvalue() });

    /* The free_token_node code block runs from p_context_delete(), not before. */
    assert_eq!(0, FREED.load(Ordering::SeqCst));
    p_context_delete(context);
    assert_eq!(2, FREED.load(Ordering::SeqCst));
}
