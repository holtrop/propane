use testparser::*;

fn main() {
    let entries: [(&str, &str, p_token_t); 51] = [
        ("byte_val", "byte", TOKEN_byte),
        ("short_val", "short", TOKEN_short),
        ("int_val", "int", TOKEN_int),
        ("long_val", "long", TOKEN_long),
        ("ssize_t_val", "ssize_t", TOKEN_ssize_t),
        ("byte_to_short", "short", TOKEN_short),
        ("byte_to_int", "int", TOKEN_int),
        ("byte_to_long", "long", TOKEN_long),
        ("byte_to_ssize_t", "ssize_t", TOKEN_ssize_t),
        ("short_to_byte", "byte", TOKEN_byte),
        ("short_to_int", "int", TOKEN_int),
        ("short_to_long", "long", TOKEN_long),
        ("short_to_ssize_t", "ssize_t", TOKEN_ssize_t),
        ("int_to_byte", "byte", TOKEN_byte),
        ("int_to_short", "short", TOKEN_short),
        ("int_to_long", "long", TOKEN_long),
        ("int_to_ssize_t", "ssize_t", TOKEN_ssize_t),
        ("long_to_byte", "byte", TOKEN_byte),
        ("long_to_short", "short", TOKEN_short),
        ("long_to_int", "int", TOKEN_int),
        ("long_to_ssize_t", "ssize_t", TOKEN_ssize_t),
        ("ssize_t_to_byte", "byte", TOKEN_byte),
        ("ssize_t_to_short", "short", TOKEN_short),
        ("ssize_t_to_int", "int", TOKEN_int),
        ("ssize_t_to_long", "long", TOKEN_long),
        ("ubyte_val", "ubyte", TOKEN_ubyte),
        ("ushort_val", "ushort", TOKEN_ushort),
        ("uint_val", "uint", TOKEN_uint),
        ("ulong_val", "ulong", TOKEN_ulong),
        ("size_t_val", "size_t", TOKEN_size_t),
        ("ubyte_to_ushort", "ushort", TOKEN_ushort),
        ("ubyte_to_uint", "uint", TOKEN_uint),
        ("ubyte_to_ulong", "ulong", TOKEN_ulong),
        ("ubyte_to_size_t", "size_t", TOKEN_size_t),
        ("ushort_to_ubyte", "ubyte", TOKEN_ubyte),
        ("ushort_to_uint", "uint", TOKEN_uint),
        ("ushort_to_ulong", "ulong", TOKEN_ulong),
        ("ushort_to_size_t", "size_t", TOKEN_size_t),
        ("uint_to_ubyte", "ubyte", TOKEN_ubyte),
        ("uint_to_ushort", "ushort", TOKEN_ushort),
        ("uint_to_ulong", "ulong", TOKEN_ulong),
        ("uint_to_size_t", "size_t", TOKEN_size_t),
        ("ulong_to_ubyte", "ubyte", TOKEN_ubyte),
        ("ulong_to_ushort", "ushort", TOKEN_ushort),
        ("ulong_to_uint", "uint", TOKEN_uint),
        ("ulong_to_size_t", "size_t", TOKEN_size_t),
        ("size_t_to_ubyte", "ubyte", TOKEN_ubyte),
        ("size_t_to_ushort", "ushort", TOKEN_ushort),
        ("size_t_to_int", "int", TOKEN_int),
        ("size_t_to_ulong", "ulong", TOKEN_ulong),
        ("main", "int", TOKEN_int),
    ];

    let mut input = String::new();
    for (name, ret, _) in entries.iter() {
        input.push_str(&format!("def {}() -> {} {{\nreturn 0x42;\n}}\n", name, ret));
    }

    let mut c = p_context_new(input.as_bytes());
    assert_eq!(P_SUCCESS, p_parse(&mut c));
    {
        let pmod = p_result(&c);
        let mut pfds = Vec::new();
        let mut pmis = pmod.pModuleItems();
        while pmis.valid() {
            let pmi = pmis.pModuleItem();
            assert!(pmi.valid());
            let pfd = pmi.pFunctionDefinition();
            if pfd.valid() {
                pfds.insert(0, pfd);
            }
            pmis = pmis.pModuleItems();
        }
        assert_eq!(51, pfds.len());
        for i in 0..pfds.len() {
            assert_eq!(entries[i].0, pfds[i].name().data().pvalue.s.as_str());
            assert_eq!(entries[i].2, pfds[i].returntype().pType().pTypeBase().pToken1().token());
        }
    }
    p_context_delete(c);
}
