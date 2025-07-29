package modules

import "core:fmt"
import "core:sys/info"

get_cpu_info :: proc() -> string {
	return fmt.tprintf("CPU: %s", info.cpu.name)
}
