package modules

import "core:os"

get_username :: proc() -> string {
	return os.get_env("USER", context.temp_allocator)
}