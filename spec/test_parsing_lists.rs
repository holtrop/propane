use testparser::*;

fn main() {
    let cases: [(&[u8], u32); 3] = [(b"a", 1), (b"", 0), (b"aaaaaaaaaaaaaaaa", 16)];
    for (input, expected) in cases {
        let mut context = p_context_new(input);
        assert_eq!(P_SUCCESS, p_parse(&mut context));
        assert_eq!(expected, p_result(&context));
        p_context_delete(context);
    }
}
