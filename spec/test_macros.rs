use testparser::*;

fn main() {
    let input = b"macro @m { 23 + 200 }\n66 + 100\n@m\n33 + 55\n@m\n";
    let mut c = p_context_new(input);
    assert_eq!(P_SUCCESS, p_parse(&mut c));
    assert_eq!(vec![166, 223, 88, 223], c.nums);
    p_context_delete(c);
}
