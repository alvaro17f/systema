package modules

import "core:fmt"
import "core:sys/info"
import "core:sys/posix"

get_kernel_info :: proc() -> string {
	uname: posix.utsname
	posix.uname(&uname)

	ver, _ := info.os_version(context.temp_allocator)

	return fmt.tprintf(
		"%s %d.%d.%d (%s)",
		ver.platform,
		ver.kernel.major,
		ver.kernel.minor,
		ver.kernel.patch,
		uname.machine,
	)
}