package modules

import "core:fmt"
import os "core:os/os2"
import "core:strconv"
import "core:strings"

@(private)
Uptime :: struct {
	days, hours, minutes, seconds: int,
}

@(private)
get_system_uptime_in_seconds :: proc() -> (int, bool) {
	file, file_err := os.open("/proc/uptime")
	defer os.close(file)
	if file_err != os.ERROR_NONE {
		return 0, false
	}

	data, err := os.read_entire_file_from_file(file, context.temp_allocator)
	if err != os.ERROR_NONE {
		return 0, false
	}

	fields := strings.fields(string(data[:]))
	defer delete(fields)

	uptime_seconds := strconv.atoi(fields[0])

	return uptime_seconds, true
}


@(private)
get_uptime :: proc(uptime: ^Uptime) {
	uptime_in_seconds, _ := get_system_uptime_in_seconds()

	uptime.days = uptime_in_seconds / 86400
	uptime.hours = (uptime_in_seconds / 3600) - (uptime.days * 24)
	uptime.minutes = (uptime_in_seconds / 60) - (uptime.hours * 60)
	uptime.seconds = uptime_in_seconds % 60
}

get_uptime_info :: proc() -> string {
	uptime: Uptime
	get_uptime(&uptime)

	uptime_string: [dynamic]u8
	defer delete(uptime_string)

	if uptime.days > 0 {
		append_string(&uptime_string, fmt.tprintf("%d days ", uptime.days))
	}

	if uptime.hours > 0 {
		append_string(&uptime_string, fmt.tprintf("%d hours ", uptime.hours))
	}

	if uptime.minutes > 0 {
		append_string(&uptime_string, fmt.tprintf("%d minutes ", uptime.minutes))
	}

	if uptime.seconds > 0 {
		append_string(&uptime_string, fmt.tprintf("%d seconds", uptime.seconds))
	}

	return strings.clone(string(uptime_string[:]), context.temp_allocator)
}
