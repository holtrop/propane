use testparser::*;

fn main() {
    let mut context = p_context_new(b"\na\n  bb ccc");
    assert_eq!(P_SUCCESS, p_parse(&mut context));
    {
        let start = p_result(&context);
        let t1 = start.pT1();
        let k1 = t1.pToken();
        let a1 = t1.pA();
        assert_eq!(2, k1.position().row);
        assert_eq!(1, k1.position().col);
        assert_eq!(2, k1.end_position().row);
        assert_eq!(1, k1.end_position().col);
        assert!(a1.position().valid());
        assert_eq!(3, a1.position().row);
        assert_eq!(3, a1.position().col);
        assert_eq!(3, a1.end_position().row);
        assert_eq!(8, a1.end_position().col);
        assert_eq!(2, t1.position().row);
        assert_eq!(1, t1.position().col);
        assert_eq!(3, t1.end_position().row);
        assert_eq!(8, t1.end_position().col);
        assert_eq!(2, start.position().row);
        assert_eq!(1, start.position().col);
        assert_eq!(3, start.end_position().row);
        assert_eq!(8, start.end_position().col);
    }
    p_context_delete(context);

    let mut context = p_context_new(b"a\nbb");
    assert_eq!(P_SUCCESS, p_parse(&mut context));
    {
        let start = p_result(&context);
        let t1 = start.pT1();
        let k1 = t1.pToken();
        let a1 = t1.pA();
        assert_eq!(1, k1.position().row);
        assert_eq!(1, k1.position().col);
        assert!(a1.position().valid());
        assert_eq!(2, a1.position().row);
        assert_eq!(1, a1.position().col);
        assert_eq!(2, a1.end_position().row);
        assert_eq!(2, a1.end_position().col);
        assert_eq!(1, t1.position().row);
        assert_eq!(2, t1.end_position().row);
        assert_eq!(2, t1.end_position().col);
        assert_eq!(1, start.position().row);
        assert_eq!(2, start.end_position().row);
        assert_eq!(2, start.end_position().col);
    }
    p_context_delete(context);

    let mut context = p_context_new(b"a\nc\nc");
    assert_eq!(P_SUCCESS, p_parse(&mut context));
    {
        let start = p_result(&context);
        let t1 = start.pT1();
        let a1 = t1.pA();
        assert!(a1.position().valid());
        assert_eq!(2, a1.position().row);
        assert_eq!(1, a1.position().col);
        assert_eq!(3, a1.end_position().row);
        assert_eq!(1, a1.end_position().col);
        assert_eq!(1, t1.position().row);
        assert_eq!(3, t1.end_position().row);
        assert_eq!(1, t1.end_position().col);
        assert_eq!(3, start.end_position().row);
        assert_eq!(1, start.end_position().col);
    }
    p_context_delete(context);

    let mut context = p_context_new(b"a");
    assert_eq!(P_SUCCESS, p_parse(&mut context));
    {
        let start = p_result(&context);
        let t1 = start.pT1();
        let a1 = t1.pA();
        assert!(!a1.position().valid());
        assert_eq!(1, t1.position().row);
        assert_eq!(1, t1.position().col);
        assert_eq!(1, t1.end_position().row);
        assert_eq!(1, t1.end_position().col);
        assert_eq!(1, start.position().row);
        assert_eq!(1, start.end_position().row);
        assert_eq!(1, start.end_position().col);
    }
    p_context_delete(context);
}
