use testparser::*;

fn main() {
    let cases: [(&[u8], u64); 4] = [
        (b"1 + 2 * 3 + 4", 11),
        (b"1 * 2 ** 4 * 3", 48),
        (b"(1 + 2) * 3 + 4", 13),
        (b"(2 * 2) ** 3 + 4 + 5", 73),
    ];
    for (input, expected) in cases {
        let mut context = p_context_new(input);
        assert_eq!(P_SUCCESS, p_parse(&mut context));
        assert_eq!(expected, p_result(&context));
        p_context_delete(context);
    }
}
