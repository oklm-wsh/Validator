open Html5
open Cmdliner

let zenburn_css  = "http://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.3.0/styles/rainbow.min.css"
let highligh_js  = "http://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.3.0/highlight.min.js"

let compute_test mail =
  try let _ = Address.List.of_string ~relax:false mail in true
  with exn -> false

let tests =
  [ compute_test, `Valid, "Mary Smith <mary@example.net>"
  ; compute_test, `Valid, "Mary Smith <mary@x.test>, jdoe@example.org, Who? <one@y.test>"
  ; compute_test, `Valid, "A Group:Ed Jones <c@a.test>,joe@where.test,John <jdoe@one.test>;"
  ; compute_test, `Valid, "Undisclosed recipients:;"
  ; compute_test, `Valid, "\"Mary Smith: Personal Account\" <smith@home.example>"
  ; compute_test, `Valid, "John Doe <jdoe@machine.example>"
  ; compute_test, `Valid, "Pete(A nice \) chap) <pete(his account)@silly.test(his host)>"
  ; compute_test, `Valid, "A Group(Some people)\r\n    :Chris Jones <c@(Chris's host.)public.example>,\r\n      joe@example.org,\r\n  John <jdoe@one.test> (my dear friend); (the end of the group)"
  ; compute_test, `Valid, "(Empty list)(start)Hidden recipients  :(nobody(that I know))  ;"
  ; compute_test, `Valid, "Mary Smith <@node.test:mary@example.net>, , jdoe@test  . example"
  ; compute_test, `Valid, "Joe Q. Public <john.q.public@example.com>"
  ; compute_test, `Valid, "John Doe <jdoe@machine(comment).  example>"
  ; compute_test, `Valid, "Mary Smith\r\n  \r\n  <mary@example.net>"
  ; compute_test, `Valid, "<boss@nil.test>, \"Giant; \\\"Big\\\" Box\" <sysservices@example.net>"
  ; compute_test, `Valid, "!#$%&`*+/=?^`{|}~@iana.org"
  ; compute_test, `Valid, "(\x07;)mary@example.net"
  ; compute_test, `Valid, "\"\\\x0a\"@x.test"
  ; compute_test, `Valid, "\"\a\"@x.test"
  ; compute_test, `Valid, "\"\x07\"@x.test"
  ; compute_test, `Valid, "\"\\\x07\"@x.test"
  ; compute_test, `Valid, "pete@[255.255.255.255]"
  ; compute_test, `Valid, "\"mary\"@example.net"
  ; compute_test, `Valid, "\"\\\"\"@example.net"
  ; compute_test, `Valid, "\"john\".\"public\"@example.com"
  ; compute_test, `Valid, "\"mary\ smith\"@home.example"
  ; compute_test, `Valid, "\"mary\".smith@home.example"
  ; compute_test, `Valid, "\"mary\\\000\"@home.example"
  ; compute_test, `Valid, " richard @home.example"
  ; compute_test, `Valid, "richar@ home .example"
  ; compute_test, `Valid, "mary . smith@y.test"
  ; compute_test, `Valid, "\x0d\x0a jdoe@example.net"
  ; compute_test, `Valid, "\x0d\x0a \x0d\x0a jdoe@example.net"
  ; compute_test, `Valid, "(comment)smith@home.example"
  ; compute_test, `Valid, "(comment(comment))smith@home.example"
  ; compute_test, `Valid, "smith@(comment)home.example"
  ; compute_test, `Valid, "smith@(comment)[255.255.255.255]"
  ; compute_test, `Valid, "robert@xn--hxajbheg2az3al.xn--jxalpdlp"
  ; compute_test, `Valid, "xn--robert@x.test"
  ; compute_test, `Valid, "stephane+blog@bortzmeyer.org"
  ; compute_test, `Valid, "{tropdur}@example.org"
  ; compute_test, `Valid, "c&a@hotmail.com"
  ; compute_test, `Valid, "directeur@arts-premiers.museum"
  ; compute_test, `Valid, "\"Stephane[Bortzmeyer]\"@laposte.net"
  ; compute_test, `Valid, "first.last@iana.org"
  ; compute_test, `Valid, "1234567890123456789012345678901234567890123456789012345678901234@iana.org"
  ; compute_test, `Valid, "\"first\\\"last\"@iana.org"
  ; compute_test, `Valid, "\"first@last\"@iana.org"
  ; compute_test, `Valid, "\"first\\last\"@iana.org"
  ; compute_test, `Valid, "first.last@[12.34.56.78]"
  ; compute_test, `Valid, "first.last@[IPv6:::12.34.56.78]"
  ; compute_test, `Valid, "first.last@[IPv6:1111:2222:3333::4444:12.34.56.78]"
  ; compute_test, `Valid, "first.last@[IPv6:1111:2222:3333:4444:5555:6666:12.34.56.78]"
  ; compute_test, `Valid, "first.last@[IPv6:::1111:2222:3333:4444:5555:6666]"
  ; compute_test, `Valid, "first.last@[IPv6:1111:2222:3333::4444:5555:6666]"
  ; compute_test, `Valid, "first.last@[IPv6:1111:2222:3333:4444:5555:6666::]"
  ; compute_test, `Valid, "first.last@[IPv6:1111:2222:3333:4444:5555:6666:7777:8888]"
  ; compute_test, `Valid, "first.last@x23456789012345678901234567890123456789012345678901234567890123.iana.org"
  ; compute_test, `Valid, "first.last@3com.com"
  ; compute_test, `Valid, "first.last@123.iana.org"
  ; compute_test, `Valid, "first.last@[IPv6:1111:2222:3333::4444:5555:12.34.56.78]"
  ; compute_test, `Valid, "first.last@[IPv6:1111:2222:3333::4444:5555:6666:7777]"
  ; compute_test, `Valid, "first.last@example.123"
  ; compute_test, `Valid, "first.last@com"
  ; compute_test, `Valid, "\"Abc\\@def\"@iana.org"
  ; compute_test, `Valid, "\"Fred\\ Bloggs\"@iana.org"
  ; compute_test, `Valid, "\"Joe.\\Blow\"@iana.org"
  ; compute_test, `Valid, "\"Abc@def\"@iana.org"
  ; compute_test, `Valid, "\"Fred Bloggs\"@iana.org"
  ; compute_test, `Valid, "user+mailbox@iana.org"
  ; compute_test, `Valid, "customer/department=shipping@iana.org"
  ; compute_test, `Valid, "$A12345@iana.org"
  ; compute_test, `Valid, "!def!xyz%abc@iana.org"
  ; compute_test, `Valid, "_somename@iana.org"
  ; compute_test, `Valid, "dclo@us.ibm.com"
  ; compute_test, `Valid, "peter.piper@iana.org"
  ; compute_test, `Valid, "\"Doug \\\"Ace\\\" L.\"@iana.org"
  ; compute_test, `Valid, "test@iana.org"
  ; compute_test, `Valid, "TEST@iana.org"
  ; compute_test, `Valid, "1234567890@iana.org"
  ; compute_test, `Valid, "test+test@iana.org"
  ; compute_test, `Valid, "test-test@iana.org"
  ; compute_test, `Valid, "t*est@iana.org"
  ; compute_test, `Valid, "+1~1+@iana.org"
  ; compute_test, `Valid, "{_test_}@iana.org"
  ; compute_test, `Valid, "\"[[ test  ]]\"@iana.org"
  ; compute_test, `Valid, "test.test@iana.org"
  ; compute_test, `Valid, "\"test.test\"@iana.org"
  ; compute_test, `Valid, "test.\"test\"@iana.org"
  ; compute_test, `Valid, "\"test@test\"@iana.org"
  ; compute_test, `Valid, "test@123.123.123.x123"
  ; compute_test, `Valid, "test@123.123.123.123"
  ; compute_test, `Valid, "test@[123.123.123.123]"
  ; compute_test, `Valid, "test@example.iana.org"
  ; compute_test, `Valid, "test@example.example.iana.org"
  ; compute_test, `Valid, "\"test\\test\"@iana.org"
  ; compute_test, `Valid, "test@example"
  ; compute_test, `Valid, "\"test\\blah\"@iana.org"
  ; compute_test, `Valid, "\"test\\\"blah\"@iana.org"
  ; compute_test, `Valid, "customer/department@iana.org"
  ; compute_test, `Valid, "_Yosemite.Sam@iana.org"
  ; compute_test, `Valid, "~@iana.org"
  ; compute_test, `Valid, "\"Austin@Powers\"@iana.org"
  ; compute_test, `Valid, "Ima.Fool@iana.org"
  ; compute_test, `Valid, "\"Ima.Fool\"@iana.org"
  ; compute_test, `Valid, "\"Ima Fool\"@iana.org"
  ; compute_test, `Valid, "\"first\".\"last\"@iana.org"
  ; compute_test, `Valid, "\"first\".middle.\"last\"@iana.org"
  ; compute_test, `Valid, "\"first\".last@iana.org"
  ; compute_test, `Valid, "first.\"last\"@iana.org"
  ; compute_test, `Valid, "\"first\".\"middle\".\"last\"@iana.org"
  ; compute_test, `Valid, "\"first.middle\".\"last\"@iana.org"
  ; compute_test, `Valid, "\"first.middle.last\"@iana.org"
  ; compute_test, `Valid, "\"first..last\"@iana.org"
  ; compute_test, `Valid, "\"first\\\\\\\"last\"@iana.org"
  ; compute_test, `Valid, "first.\"mid\\dle\".\"last\"@iana.org"
  ; compute_test, `Valid, "\"test blah\"@iana.org"
  ; compute_test, `Valid, "(foo)cal(bar)@(baz)iamcal.com(quux)"
  ; compute_test, `Valid, "cal@iamcal(woo).(yay)com"
  ; compute_test, `Valid, "cal(woo(yay)hoopla)@iamcal.com"
  ; compute_test, `Valid, "cal(foo\\@bar)@iamcal.com"
  ; compute_test, `Valid, "cal(foo\\)bar)@iamcal.com"
  ; compute_test, `Valid, "first().last@iana.org"
  ; compute_test, `Valid, "pete(his account)@silly.test(his host)"
  ; compute_test, `Valid, "c@(Chris's host.)public.example"
  ; compute_test, `Valid, "jdoe@machine(comment). example"
  ; compute_test, `Valid, "1234 @ local(blah) .machine .example"
  ; compute_test, `Valid, "first(abc.def).last@iana.org"
  ; compute_test, `Valid, "first(a\"bc.def).last@iana.org"
  ; compute_test, `Valid, "first.(\")middle.last(\")@iana.org"
  ; compute_test, `Valid, "first(abc\\(def)@iana.org"
  ; compute_test, `Valid, "first.last@x(1234567890123456789012345678901234567890123456789012345678901234567890).com"
  ; compute_test, `Valid, "a(a(b(c)d(e(f))g)h(i)j)@iana.org"
  ; compute_test, `Valid, "name.lastname@domain.com"
  ; compute_test, `Valid, "a@b"
  ; compute_test, `Valid, "a@bar.com"
  ; compute_test, `Valid, "aaa@[123.123.123.123]"
  ; compute_test, `Valid, "a@bar"
  ; compute_test, `Valid, "a-b@bar.com"
  ; compute_test, `Valid, "+@b.c"
  ; compute_test, `Valid, "+@b.com"
  ; compute_test, `Valid, "a@b.co-foo.uk"
  ; compute_test, `Valid, "\"hello my name is\"@stutter.com"
  ; compute_test, `Valid, "\"Test \\\"Fail\\\" Ing\"@iana.org"
  ; compute_test, `Valid, "valid@about.museum"
  ; compute_test, `Valid, "shaitan@my-domain.thisisminekthx"
  ; compute_test, `Valid, "foobar@192.168.0.1"
  ; compute_test, `Valid, "\"Joe\\Blow\"@iana.org"
  ; compute_test, `Valid, "HM2Kinsists@(that comments are allowed)this.is.ok"
  ; compute_test, `Valid, "user%uucp!path@berkeley.edu"
  ; compute_test, `Valid, "first.last @iana.org"
  ; compute_test, `Valid, "cdburgess+!#$%&'*-/=?+_{}|~test@gmail.com"
  ; compute_test, `Valid, "first.last@[IPv6:a1:a2:a3:a4:b1:b2:b3::]"
  ; compute_test, `Valid, "first.last@[IPv6:::]"
  ; compute_test, `Valid, "first.last@[IPv6:::b4]"
  ; compute_test, `Valid, "first.last@[IPv6:::b3:b4]"
  ; compute_test, `Valid, "first.last@[IPv6:a1::b4]"
  ; compute_test, `Valid, "first.last@[IPv6:a1::]"
  ; compute_test, `Valid, "first.last@[IPv6:a1:a2::]"
  ; compute_test, `Valid, "first.last@[IPv6:0123:4567:89ab:cdef::]"
  ; compute_test, `Valid, "first.last@[IPv6:0123:4567:89ab:CDEF::]"
  ; compute_test, `Valid, "first.last@[IPv6:::a3:a4:b1:ffff:11.22.33.44]"
  ; compute_test, `Valid, "first.last@[IPv6:a1:a2:a3:a4::11.22.33.44]"
  ; compute_test, `Valid, "first.last@[IPv6:a1:a2:a3:a4:b1::11.22.33.44]"
  ; compute_test, `Valid, "first.last@[IPv6:a1::11.22.33.44]"
  ; compute_test, `Valid, "first.last@[IPv6:a1:a2::11.22.33.44]"
  ; compute_test, `Valid, "first.last@[IPv6:0123:4567:89ab:cdef::11.22.33.44]"
  ; compute_test, `Valid, "first.last@[IPv6:0123:4567:89ab:CDEF::11.22.33.44]"
  ; compute_test, `Valid, "first.last@[IPv6:a1::b2:11.22.33.44]"
  ; compute_test, `Valid, "first.last@[IPv6:::a2:a3:a4:b1:b2:b3:b4]"
  ; compute_test, `Valid, "first.last@[IPv6:::a2:a3:a4:b1:ffff:11.22.33.44]"
  ; compute_test, `Valid, "test@test.com"
  ; compute_test, `Valid, "test@xn--example.com"
  ; compute_test, `Valid, "test@example.com"
  ; compute_test, `Invalid, ""
  ; compute_test, `Invalid, "mary"
  ; compute_test, `Invalid, "@"
  ; compute_test, `Invalid, "mary@"
  ; compute_test, `Invalid, "@io"
  ; compute_test, `Invalid, "@example.net"
  ; compute_test, `Invalid, ".mary@example.net"
  ; compute_test, `Invalid, "jdoe.@example.net"
  ; compute_test, `Invalid, "pete..silly.test"
  ; compute_test, `Invalid, "sm_i-th.com"
  ; compute_test, `Invalid, "mary\@jdoe@one.test"
  ; compute_test, `Invalid, "jdoe@.one.test"
  ; compute_test, `Invalid, "jdon@one.test."
  ; compute_test, `Invalid, "boss@nil..test"
  ; compute_test, `Invalid, "\"\"\"@example.net"
  ; compute_test, `Invalid, "\"\\\"@example.net"
  ; compute_test, `Invalid, "jdoe\"@machine.example"
  ; compute_test, `Invalid, "\"jdoe@machine.example"
  ; compute_test, `Invalid, "\"john\"public@example.com"
  ; compute_test, `Invalid, "john\"public\"@example.com"
  ; compute_test, `Invalid, "\"john\"\"public\"@example.com"
  ; compute_test, `Invalid, "\"mary\000\"@home.example"
  ; compute_test, `Invalid, "pete@a[255.255.255.255]"
  ; compute_test, `Invalid, "((comment)smith@home.example"
  ; compute_test, `Invalid, "smith(coment)doe@home.example"
  ; compute_test, `Invalid, "robert@henry.com\r"
  ; compute_test, `Invalid, "(smith@home.example"
  ; compute_test, `Invalid, "robert@[1.2.3.4"
  ; compute_test, `Invalid, "\"john\\\"@example.com"
  ; compute_test, `Invalid, "(comment\\)smith@home.example"
  ; compute_test, `Invalid, "smith@home.example(comment\\)"
  ; compute_test, `Invalid, "smith@home.example(comment\\"
  ; compute_test, `Invalid, "robert@[RFC5322-[domain-literal\\]"
  ; compute_test, `Invalid, "robert@[RFC5322-[domain-literal]"
  ; compute_test, `Invalid, "robert@[RFC5322-[domain-literal\\"
  ; compute_test, `Invalid, "marx@capitalism.ru\x0d"
  ; compute_test, `Invalid, "\x0dmarx@capitalism.ru"
  ; compute_test, `Invalid, "\"\x0dmarx\"@capitalism.ru"
  ; compute_test, `Invalid, "(\x0d)marx@capitalism.ru"
  ; compute_test, `Invalid, "marx@capitalism.ru(\x0d)"
  ; compute_test, `Invalid, "smith@communism.uk\x0a"
  ; compute_test, `Invalid, "\x0asmith@communism.uk"
  ; compute_test, `Invalid, "\"\x0asmith\"@communism.uk"
  ; compute_test, `Invalid, "(\x0a)smith@communism.uk"
  ; compute_test, `Invalid, "smith@communism.uk(\x0a)"
  ; compute_test, `Invalid, "first.last@sub.do,com"
  ; compute_test, `Invalid, "first\\@last@iana.org"
  ; compute_test, `Invalid, "first.last"
  ; compute_test, `Invalid, ".first.last@iana.org"
  ; compute_test, `Invalid, "first.last.@iana.org"
  ; compute_test, `Invalid, "first..last@iana.org"
  ; compute_test, `Invalid, "\"first\"last\"@iana.org"
  ; compute_test, `Invalid, "\"\"\"@iana.org"
  ; compute_test, `Invalid, "\"\\\"@iana.org"
  ; compute_test, `Invalid, "\"\"@iana.org"
  ; compute_test, `Invalid, "first\\@last@iana.org"
  ; compute_test, `Invalid, "first.last@"
  ; compute_test, `Invalid, "first.last@[.12.34.56.78]"
  ; compute_test, `Invalid, "first.last@[12.34.56.789]"
  ; compute_test, `Invalid, "first.last@[::12.34.56.78]"
  ; compute_test, `Invalid, "first.last@[IPv5:::12.34.56.78]"
  ; compute_test, `Invalid, "first.last@[IPv6:1111:2222:3333:4444:5555:12.34.56.78]"
  ; compute_test, `Invalid, "first.last@[IPv6:1111:2222:3333:4444:5555:6666:7777:12.34.56.78]"
  ; compute_test, `Invalid, "first.last@[IPv6:1111:2222:3333:4444:5555:6666:7777]"
  ; compute_test, `Invalid, "first.last@[IPv6:1111:2222:3333:4444:5555:6666:7777:8888:9999]"
  ; compute_test, `Invalid, "first.last@[IPv6:1111:2222::3333::4444:5555:6666]"
  ; compute_test, `Invalid, "first.last@[IPv6:1111:2222:333x::4444:5555]"
  ; compute_test, `Invalid, "first.last@[IPv6:1111:2222:33333::4444:5555]"
  ; compute_test, `Invalid, "abc\\@def@iana.org"
  ; compute_test, `Invalid, "abc\\@iana.org"
  ; compute_test, `Invalid, "@iana.org"
  ; compute_test, `Invalid, "doug@"
  ; compute_test, `Invalid, "\"qu@iana.org"
  ; compute_test, `Invalid, "ote\"@iana.org"
  ; compute_test, `Invalid, ".dot@iana.org"
  ; compute_test, `Invalid, "dot.@iana.org"
  ; compute_test, `Invalid, "two..dot@iana.org"
  ; compute_test, `Invalid, "\"Doug \"Ace\" L.\"@iana.org"
  ; compute_test, `Invalid, "Doug\\ \\\"Ace\\\"\\ L\\.@iana.org"
  ; compute_test, `Invalid, "hello world@iana.org"
  ; compute_test, `Invalid, "gatsby@f.sc.ot.t.f.i.tzg.era.l.d."
  ; compute_test, `Invalid, "test.iana.org"
  ; compute_test, `Invalid, "test.@iana.org"
  ; compute_test, `Invalid, "test..test@iana.org"
  ; compute_test, `Invalid, ".test@iana.org"
  ; compute_test, `Invalid, "test@test@iana.org"
  ; compute_test, `Invalid, "test@@iana.org"
  ; compute_test, `Invalid, "-- test --@iana.org"
  ; compute_test, `Invalid, "[test]@iana.org"
  ; compute_test, `Invalid, "\"test\"test\"@iana.org"
  ; compute_test, `Invalid, "()[]\;:,><@iana.org"
  ; compute_test, `Invalid, "test@."
  ; compute_test, `Invalid, "test@example."
  ; compute_test, `Invalid, "test@.org"
  ; compute_test, `Invalid, "test@[123.123.123.123"
  ; compute_test, `Invalid, "test@123.123.123.123]"
  ; compute_test, `Invalid, "NotAnEmail"
  ; compute_test, `Invalid, "NotAnEmail"
  ; compute_test, `Invalid, "\"test\"blah\"@iana.org"
  ; compute_test, `Invalid, ".wooly@iana.org"
  ; compute_test, `Invalid, "wo..oly@iana.org"
  ; compute_test, `Invalid, "pootietang.@iana.org"
  ; compute_test, `Invalid, ".@iana.org"
  ; compute_test, `Invalid, "Ima Fool@iana.org"
  ; compute_test, `Invalid, "phil.h\\@\\@ck@haacked.com"
  ; compute_test, `Invalid, "first\\last@iana.org"
  ; compute_test, `Invalid, "Abc\\@def@iana.org"
  ; compute_test, `Invalid, "Fred\\ Bloggs@iana.org"
  ; compute_test, `Invalid, "Joe.\\Blow@iana.org"
  ; compute_test, `Invalid, "first.last@[IPv6:1111:2222:3333:4444:5555:6666:12.34.567.89]"
  ; compute_test, `Invalid, "{^c\\@**Dog^}@cartoon.com"
  ; compute_test, `Invalid, "cal(foo(bar)@iamcal.com"
  ; compute_test, `Invalid, "cal(foo\\)@iamcal.com"
  ; compute_test, `Invalid, "cal(foo)bar)@iamcal.com"
  ; compute_test, `Invalid, "first(middle)last@iana.org"
  ; compute_test, `Invalid, "a(a(b(c)d(e(f))g)(h(i)j)@iana.org"
  ; compute_test, `Invalid, ".@"
  ; compute_test, `Invalid, "@bar.com"
  ; compute_test, `Invalid, "@@bar.com"
  ; compute_test, `Invalid, "aaa.com"
  ; compute_test, `Invalid, "aaa@.com"
  ; compute_test, `Invalid, "aaa@.com"
  ; compute_test, `Invalid, "aaa@.123"
  ; compute_test, `Invalid, "aaa@[123.123.123.123]a"
  ; compute_test, `Invalid, "aaa@[123.123.123.333]"
  ; compute_test, `Invalid, "a@bar.com."
  ; compute_test, `Invalid, "-@..com"
  ; compute_test, `Invalid, "-@a..com"
  ; compute_test, `Invalid, "test@...........com"
  ; compute_test, `Invalid, "\"\000 \"@char.com"
  ; compute_test, `Invalid, "\000@char.com"
  ; compute_test, `Invalid, "first.last@[IPv6::]"
  ; compute_test, `Invalid, "first.last@[IPv6::::]"
  ; compute_test, `Invalid, "first.last@[IPv6::b4]"
  ; compute_test, `Invalid, "first.last@[IPv6::::b4]"
  ; compute_test, `Invalid, "first.last@[IPv6::b3:b4]"
  ; compute_test, `Invalid, "first.last@[IPv6::::b3:b4]"
  ; compute_test, `Invalid, "first.last@[IPv6:a1:::b4]"
  ; compute_test, `Invalid, "first.last@[IPv6:a1:]"
  ; compute_test, `Invalid, "first.last@[IPv6:a1:::]"
  ; compute_test, `Invalid, "first.last@[IPv6:a1:a2:]"
  ; compute_test, `Invalid, "first.last@[IPv6:a1:a2:::]"
  ; compute_test, `Invalid, "first.last@[IPv6::11.22.33.44]"
  ; compute_test, `Invalid, "first.last@[IPv6::::11.22.33.44]"
  ; compute_test, `Invalid, "first.last@[IPv6:a1:11.22.33.44]"
  ; compute_test, `Invalid, "first.last@[IPv6:a1:::11.22.33.44]"
  ; compute_test, `Invalid, "first.last@[IPv6:a1:a2:::11.22.33.44]"
  ; compute_test, `Invalid, "first.last@[IPv6:0123:4567:89ab:cdef::11.22.33.xx]"
  ; compute_test, `Invalid, "first.last@[IPv6:0123:4567:89ab:CDEFF::11.22.33.44]"
  ; compute_test, `Invalid, "first.last@[IPv6:a1::a4:b1::b4:11.22.33.44]"
  ; compute_test, `Invalid, "first.last@[IPv6:a1::11.22.33]"
  ; compute_test, `Invalid, "first.last@[IPv6:a1::11.22.33.44.55]"
  ; compute_test, `Invalid, "first.last@[IPv6:a1::b211.22.33.44]"
  ; compute_test, `Invalid, "first.last@[IPv6:a1::11.22.33]"
  ; compute_test, `Invalid, "first.last@[IPv6:a1::11.22.33.44.55]"
  ; compute_test, `Invalid, "first.last@[IPv6:a1::b211.22.33.44]"
  ; compute_test, `Invalid, "first.last@[IPv6:a1::b2::11.22.33.44]"
  ; compute_test, `Invalid, "first.last@[IPv6:a1::b3:]"
  ; compute_test, `Invalid, "first.last@[IPv6::a2::b4]"
  ; compute_test, `Invalid, "first.last@[IPv6:a1:a2:a3:a4:b1:b2:b3:]"
  ; compute_test, `Invalid, "first.last@[IPv6::a2:a3:a4:b1:b2:b3:b4]"
  ; compute_test, `Invalid, "first.last@[IPv6:a1:a2:a3:a4::b1:b2:b3:b4]"
  ; compute_test, `Invalid, "=?us-ascii?Q?Chri's_Smith?= =?us-ascii?Q?Henry?= <.@gmail.com,@hotmail.fr:henry.chris+porno@(Chris's host.)public.example> (je suis un connard en puissance)" ]

let make_example (test, expected, mail) =
  let right = match test mail, expected with
  | true, `Valid ->
    M.div ~a:[M.a_class ["valid"; "result"]] [ M.pcdata "Valid!" ]
  | false, `Valid ->
    M.div ~a:[M.a_class ["error"; "result"]] [ M.pcdata "Expected Valid!" ]
  | false, `Invalid ->
    M.div ~a:[M.a_class ["invalid"; "result"]] [ M.pcdata "Invalid!" ]
  | true, `Invalid ->
    M.div ~a:[M.a_class ["error"; "result"]] [ M.pcdata "Expected Invalid!" ]
  in
  M.li
  [ M.div ~a:[M.a_class ["mail"]]
    [ M.pre [ M.code ~a:[M.a_class ["string"]] [ M.pcdata (Printf.sprintf "%S" mail) ]] ]
    ; right ]

let script = function
  | None -> M.html (M.head (M.title (M.pcdata "Validator")) []) (M.body [])
  | Some script ->
    M.html
      (M.head
       (M.title (M.pcdata "Validator"))
       [ M.meta ~a:[ M.a_http_equiv "content-type"
                   ; M.a_content "text/html; charset=utf-8"] ()
       ; M.link ~rel:[`Stylesheet]
                ~href:(Xml.uri_of_string "web/style.css")
                ~a:[M.a_mime_type "text/css"] ()
       ; M.script ~a:[ M.a_src @@ Xml.uri_of_string highligh_js ] @@ M.pcdata ""
       ; M.link ~rel:[`Stylesheet]
                ~href:(Xml.uri_of_string zenburn_css)
                ~a:[M.a_mime_type "text/css"] ()])
      (M.body ~a:[ M.a_id "main" ]
       [ M.form ~a:[ M.a_class ["field"]; M.a_id "validate" ]
           [ M.input ~a:[ M.a_input_type `Text
                      ; M.a_id "validate-term"
                      ; M.a_placeholder "the hell email" ] ()
           ; M.input ~a:[ M.a_input_type `Submit
                        ; M.a_id "validate-button"
                        ; M.a_value "Check!" ] ()]
       ; M.div ~a:[ M.a_class ["example"]; M.a_id "example" ]
         [ M.ul (List.map make_example tests) ]
       ; M.script ~a:[ M.a_src @@ Xml.uri_of_string script ] @@ M.pcdata "" ])

let main s =
  let p = print_string in
  let c = script s in
  P.print ~output:p c;
  `Ok ()

let script =
  let doc = "Script JS" in
  Arg.(value & opt (some string) None & info ["s"; "script"] ~docv:"script" ~doc)

let cmd =
  let doc = "Rendering validator page" in
  let man =
  [ `P "BUGS"
  ; `S "Email them to <romain.calascibetta@gmail.com>" ]
  in Term.(ret (pure main $ script)), Term.info "to_html" ~version:"0.1" ~doc ~man

let () =
  match Term.eval cmd with
  | `Error _ -> exit 1
  | _        -> exit 0