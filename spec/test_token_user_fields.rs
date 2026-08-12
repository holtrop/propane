use testparser::*;

fn main() {
    let input = b"# c1\n#  c2\n\nfirst\n\n   \n  \n  # s1\n   #   s2\nsecond\n";
    let mut c = p_context_new(input);
    assert_eq!(P_SUCCESS, p_parse(&mut c));
    {
        let start = p_result(&c);
        assert!(start.pIDs().valid());
        assert!(start.pIDs().id().valid());
        assert_eq!("# c1\n#  c2\n", start.pIDs().id().data().comments.as_str());
        assert!(start.pIDs().pIDs().valid());
        assert!(start.pIDs().pIDs().id().valid());
        assert_eq!("# s1\n#   s2\n", start.pIDs().pIDs().id().data().comments.as_str());
    }
    p_context_delete(c);
}
