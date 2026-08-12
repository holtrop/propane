use testparser::*;

fn main() {
    let mut c = p_context_new(b"    # comment 1\n#    comment 2\na\n");
    assert_eq!(P_SUCCESS, p_parse(&mut c));
    p_context_delete(c);
}
