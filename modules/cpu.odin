package modules

import "core:fmt"
import "core:sys/info"

get_cpu_info :: proc() -> string {
	return fmt.tprintf("%s", info.cpu.name)
}
