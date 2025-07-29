package modules

import "core:fmt"
import os "core:os/os2"
import "core:strings"

get_shell_info :: proc() -> string {
	shell_raw := os.get_env("SHELL", context.temp_allocator)
	i := strings.last_index(shell_raw, "/")
	return fmt.tprintf("Shell: %s", shell_raw[i + 1:])
}
