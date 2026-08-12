use testparser::*;

fn chk(ti: &p_token_info_t, row: u32, col: u32, erow: u32, ecol: u32, len: usize, token: p_token_t) {
    assert_eq!(row, ti.position.row);
    assert_eq!(col, ti.position.col);
    assert_eq!(erow, ti.end_position.row);
    assert_eq!(ecol, ti.end_position.col);
    assert_eq!(len, ti.length);
    assert_eq!(token, ti.token);
}

fn main() {
    let mut cp: p_code_point_t = 0;
    let mut cpl: u8 = 0;

    assert_eq!(P_SUCCESS, p_decode_code_point(b"5", &mut cp, &mut cpl));
    assert_eq!('5' as u32, cp);
    assert_eq!(1, cpl);

    assert_eq!(P_EOF, p_decode_code_point(b"", &mut cp, &mut cpl));

    assert_eq!(P_SUCCESS, p_decode_code_point(b"\xC2\xA9", &mut cp, &mut cpl));
    assert_eq!(0xA9, cp);
    assert_eq!(2, cpl);

    assert_eq!(P_SUCCESS, p_decode_code_point(b"\xf0\x9f\xa7\xa1", &mut cp, &mut cpl));
    assert_eq!(0x1F9E1, cp);
    assert_eq!(4, cpl);

    assert_eq!(P_DECODE_ERROR, p_decode_code_point(b"\xf0\x9f\x27", &mut cp, &mut cpl));
    assert_eq!(P_DECODE_ERROR, p_decode_code_point(b"\xf0\x9f\xa7\xFF", &mut cp, &mut cpl));
    assert_eq!(P_DECODE_ERROR, p_decode_code_point(b"\xfe", &mut cp, &mut cpl));

    let mut context = p_context_new(b"5 + 4 * \n677 + 567");
    let mut ti = p_token_info_t::default();
    assert_eq!(P_SUCCESS, p_lex(&mut context, &mut ti)); chk(&ti, 1, 1, 1, 1, 1, TOKEN_int);
    assert_eq!(P_SUCCESS, p_lex(&mut context, &mut ti)); chk(&ti, 1, 3, 1, 3, 1, TOKEN_plus);
    assert_eq!(P_SUCCESS, p_lex(&mut context, &mut ti)); chk(&ti, 1, 5, 1, 5, 1, TOKEN_int);
    assert_eq!(P_SUCCESS, p_lex(&mut context, &mut ti)); chk(&ti, 1, 7, 1, 7, 1, TOKEN_times);
    assert_eq!(P_SUCCESS, p_lex(&mut context, &mut ti)); chk(&ti, 2, 1, 2, 3, 3, TOKEN_int);
    assert_eq!(P_SUCCESS, p_lex(&mut context, &mut ti)); chk(&ti, 2, 5, 2, 5, 1, TOKEN_plus);
    assert_eq!(P_SUCCESS, p_lex(&mut context, &mut ti)); chk(&ti, 2, 7, 2, 9, 3, TOKEN_int);
    assert_eq!(P_SUCCESS, p_lex(&mut context, &mut ti)); chk(&ti, 2, 10, 2, 10, 0, TOKEN___EOF);
    p_context_delete(context);

    let mut context = p_context_new(b"");
    assert_eq!(P_SUCCESS, p_lex(&mut context, &mut ti)); chk(&ti, 1, 1, 1, 1, 0, TOKEN___EOF);
    p_context_delete(context);
}
