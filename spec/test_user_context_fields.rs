use testparser::*;

fn main() {
    let mut c = p_context_new(b"aaa\n\n\na\n    # comment 1\na  a    aa\n\naa\n#    comment 2\na\n");
    assert_eq!(P_SUCCESS, p_parse(&mut c));
    eprint!("comments: {}", c.comments);
    eprintln!("acount: {}", c.acount);
    p_context_delete(c);
}
