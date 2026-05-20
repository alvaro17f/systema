package modules

import "core:fmt"
import "core:os"

Desktop :: struct {
	desktop, session: string,
}

get_desktop_info :: proc() -> string {
	desktop_env := os.get_env("XDG_CURRENT_DESKTOP", context.temp_allocator)
	session_env := os.get_env("XDG_SESSION_TYPE", context.temp_allocator)

	desktop: Desktop
	desktop.desktop = desktop_env == "" ? "Unknown" : desktop_env
	desktop.session = session_env == "" ? "Unknown" : session_env

	return fmt.tprintf("%s (%s)", desktop.desktop, desktop.session)
}