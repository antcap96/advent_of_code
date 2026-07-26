app [main!] {
	pf: platform "https://github.com/lukewilliamboswell/roc-platform-template-zig/releases/download/1.0.0/AnZoxzoGPtSGQ15EQh6pBeeaHJ7aizP9MQhK81dES3Uq.tar.zst",
}

import pf.Stdout

f1 = || {
	Err(A)
}

f2 = || {
	Err(B)
}

main! : _ => Try(_, [_])
main! = |_args| {
	f1()?
	f2()?
	Stdout.line!("Ok")
}
