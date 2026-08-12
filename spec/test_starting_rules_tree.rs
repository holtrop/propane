use testparser::*;

fn main() {
    let mut c = p_context_new(b"bbbb");
    assert_eq!(P_SUCCESS, p_parse(&mut c));
    {
        let start = p_result(&c);
        assert!(start.bs().valid());
        assert!(start.bs().b().valid());
        assert!(start.bs().bs().b().valid());
        assert!(start.bs().bs().bs().b().valid());
        assert!(start.bs().bs().bs().bs().b().valid());
    }
    p_context_delete(c);

    let mut c = p_context_new(b"bbbb");
    assert_eq!(P_SUCCESS, p_parse_Bs(&mut c));
    {
        let bs = p_result_Bs(&c);
        assert!(bs.b().valid());
        assert!(bs.bs().b().valid());
        assert!(bs.bs().bs().b().valid());
        assert!(bs.bs().bs().bs().b().valid());
    }
    p_context_delete(c);

    let mut c = p_context_new(b"c");
    assert_eq!(P_SUCCESS, p_parse_R(&mut c));
    {
        let r = p_result_R(&c);
        assert!(r.c().valid());
    }
    p_context_delete(c);
}
