package modules

import "core:fmt"
import "core:strings"
import "core:sys/info"

get_system_info :: proc() -> string {
	ver, _ := info.os_version(context.temp_allocator)
	i := strings.index(ver.full, ",")
	return ver.full[:i]
}