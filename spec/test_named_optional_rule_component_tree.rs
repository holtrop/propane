use testparser::*;

fn main() {
    let mut context = p_context_new(b"b");
    assert_eq!(P_SUCCESS, p_parse(&mut context));
    {
        let start = p_result(&context);
        assert!(!start.a().valid());
        assert!(start.pToken2().valid());
        assert_eq!(TOKEN_b, start.pToken2().token());
        assert!(!start.pR3().valid());
        assert!(!start.pR().valid());
        assert!(!start.r().valid());
    }
    p_context_delete(context);

    let mut context = p_context_new(b"abcd");
    assert_eq!(P_SUCCESS, p_parse(&mut context));
    {
        let start = p_result(&context);
        assert!(start.a().valid());
        assert_eq!(TOKEN_a, start.pToken1().token());
        assert!(start.pToken2().valid());
        assert!(start.pR3().valid());
        assert!(start.pR().valid());
        assert!(start.r().valid());
        assert_eq!(start.pR().node_id(), start.pR3().node_id());
        assert_eq!(start.pR().node_id(), start.r().node_id());
        assert_eq!(TOKEN_c, start.pR().pToken1().token());
    }
    p_context_delete(context);

    let mut context = p_context_new(b"bdc");
    assert_eq!(P_SUCCESS, p_parse(&mut context));
    {
        let start = p_result(&context);
        assert!(!start.a().valid());
        assert!(start.pToken2().valid());
        assert!(start.r().valid());
        assert_eq!(TOKEN_d, start.pR().pToken1().token());
    }
    p_context_delete(context);
}
