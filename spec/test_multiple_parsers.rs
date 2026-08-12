use testparsermyp1 as m1;
use testparsermyp2 as m2;

fn main() {
    let mut context1 = m1::myp1_context_new(b"a\n1");
    assert_eq!(m1::P_SUCCESS, m1::myp1_parse(&mut context1));
    m1::myp1_context_delete(context1);

    let mut context2 = m2::myp2_context_new(b"bcb");
    assert_eq!(m2::P_SUCCESS, m2::myp2_parse(&mut context2));
    m2::myp2_context_delete(context2);
}
