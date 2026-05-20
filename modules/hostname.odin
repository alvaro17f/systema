package modules

import "core:sys/posix"

get_hostname :: proc() -> [65]u8 {
	uname: posix.utsname
	posix.uname(&uname)

	return uname.nodename
}
