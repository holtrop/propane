use testparser::*;

fn main() {
    let input = b"a, ((b)), b";
    let mut context = p_context_new(input);
    assert_eq!(P_SUCCESS, p_parse(&mut context));
    {
        let start = p_result(&context);
        assert!(start.pItems1().valid());
        assert!(start.pItems().valid());
        let items = start.pItems();
        assert!(items.pItem().valid());
        assert!(items.pItem().pToken1().valid());
        assert_eq!(TOKEN_a, items.pItem().pToken1().token());
        assert_eq!(11, items.pItem().pToken1().pvalue());
        let itemsmore = items.pItemsMore();
        assert!(itemsmore.pItem().pItem().pItem().pToken1().valid());
        assert_eq!(TOKEN_b, itemsmore.pItem().pItem().pItem().pToken1().token());
        assert_eq!(22, itemsmore.pItem().pItem().pItem().pToken1().pvalue());
        assert!(itemsmore.pItemsMore().valid());
        let itemsmore = itemsmore.pItemsMore();
        assert_eq!(TOKEN_b, itemsmore.pItem().pToken1().token());
        assert!(!itemsmore.pItemsMore().valid());
    }
    p_context_delete(context);

    /* Empty input yields a Start node with no Items child. */
    let mut context = p_context_new(b"");
    assert_eq!(P_SUCCESS, p_parse(&mut context));
    assert!(!p_result(&context).pItems().valid());
    p_context_delete(context);

    /* Dual rule alternative field positions. */
    let mut context = p_context_new(b"2 1");
    assert_eq!(P_SUCCESS, p_parse(&mut context));
    {
        let start = p_result(&context);
        assert!(start.pItems().pItem().pDual().pTwo1().valid());
        assert!(start.pItems().pItem().pDual().pOne2().valid());
        assert!(!start.pItems().pItem().pDual().pTwo2().valid());
        assert!(!start.pItems().pItem().pDual().pOne1().valid());
    }
    p_context_delete(context);

    println!("ok");
}
