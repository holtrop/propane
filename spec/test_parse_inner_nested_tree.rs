use testparser::*;

fn main() {
    let mut c = p_context_new(b"(3 + 4) + (5 + 6)");
    assert_eq!(P_SUCCESS, p_parse(&mut c));
    {
        let tree = p_result(&c);
        assert!(tree.valid());

        /* Start -> Expr, where the top Expr is "Expr plus num". */
        let top = tree.pExpr();
        assert!(top.valid());
        assert!(top.pExpr().valid());
        assert!(top.pToken2().valid());
        assert!(top.pToken3().valid());

        /* The '+' joining the two groups is at column 9. */
        assert_eq!(1, top.pToken2().position().row);
        assert_eq!(9, top.pToken2().position().col);

        /* Right operand: synthesized num for "(5 + 6)", columns 11..17. */
        assert_eq!(11, top.pToken3().position().col);
        assert_eq!(17, top.pToken3().end_position().col);

        /* Left operand: synthesized num for "(3 + 4)", columns 1..7. */
        let left = top.pExpr();
        assert!(left.pToken1().valid());
        assert_eq!(1, left.pToken1().position().col);
        assert_eq!(7, left.pToken1().end_position().col);

        /* The whole tree spans columns 1..17. */
        assert_eq!(1, tree.position().col);
        assert_eq!(17, tree.end_position().col);
    }
    p_context_delete(c);
}
