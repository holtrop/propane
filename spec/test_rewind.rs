use testparser::*;

fn main() {
    /* "repeat 3 { 10 + 20 } 5 + 5": the body "10 + 20" is expanded three
     * times (recording 30 each time), followed by "5 + 5" (recording 10). */
    let mut c = p_context_new(b"repeat 3 { 10 + 20 } 5 + 5");
    assert_eq!(P_SUCCESS, p_parse(&mut c));

    assert_eq!(vec![30, 30, 30, 10], c.nums);
    assert_eq!(vec![12, 17, 12, 17, 12, 17, 22, 26], c.num_cols);

    p_context_delete(c);
}
