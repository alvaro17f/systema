package modules

import "core:fmt"
import "core:sys/info"
import "core:sys/posix"

get_kernel_info :: proc() -> string {
	uname: posix.utsname
	posix.uname(&uname)

	return fmt.tprintf(
		"%s %d.%d.%d (%s)",
		info.os_version.platform,
		info.os_version.major,
		info.os_version.minor,
		info.os_version.patch,
		uname.machine,
	)
}
