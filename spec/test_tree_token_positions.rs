use testparser::*;

fn main() {
    let input = b"abbccc";
    let mut context = p_context_new(input);
    assert_eq!(P_SUCCESS, p_parse(&mut context));
    {
        let start = p_result(&context);
        let t1 = start.pT1();
        let t2 = start.pT2();
        let t3 = start.pT3();
        assert_eq!(1, t1.position().col);
        assert_eq!(1, t1.end_position().col);
        assert_eq!(2, t2.position().col);
        assert_eq!(3, t2.end_position().col);
        assert_eq!(4, t3.position().col);
        assert_eq!(6, t3.end_position().col);
        /* Token node position within T1. */
        assert_eq!(1, t1.pToken().position().col);
        /* Overall start node spans the whole input. */
        assert_eq!(1, start.position().col);
        assert_eq!(6, start.end_position().col);
        assert_eq!(3, start.n_fields());
    }
    p_context_delete(context);
    println!("ok");
}
