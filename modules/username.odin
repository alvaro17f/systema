package modules

import os "core:os/os2"

get_username :: proc() -> string {
	return os.get_env("USER", context.temp_allocator)
}
