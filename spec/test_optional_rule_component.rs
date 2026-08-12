use testparser::*;

fn main() {
    for input in [&b"b"[..], &b"abcd"[..], &b"abdc"[..]] {
        let mut context = p_context_new(input);
        assert_eq!(P_SUCCESS, p_parse(&mut context));
        p_context_delete(context);
    }
}
