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

    /* The free_token_node code block runs when the context is disposed of, not
     * before, and frees each of the two token nodes exactly once. */
    assert_eq!(0, FREED.load(Ordering::SeqCst));
    p_context_delete(context);
    assert_eq!(2, FREED.load(Ordering::SeqCst));

    /* Letting the context go out of scope runs the code block too, so a caller
     * which never calls p_context_delete() does not leak. */
    {
        let mut context = p_context_new(b"ab");
        assert_eq!(P_SUCCESS, p_parse(&mut context));
        assert_eq!(2, FREED.load(Ordering::SeqCst));
    }
    assert_eq!(4, FREED.load(Ordering::SeqCst));
}
