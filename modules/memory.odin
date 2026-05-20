package modules

import "core:fmt"
import os "core:os/os2"
import "core:strconv"
import "core:strings"
import "../colors"

@(private)
Memory :: struct {
	total, available, used, used_percent: f64,
}

@(private)
get_meminfo :: proc(memory: ^Memory) -> (err: os.Error) {
	file, file_err := os.open("/proc/meminfo")
	defer os.close(file)
	if file_err != os.ERROR_NONE {
		return file_err
	}

	data, read_err := os.read_entire_file_from_file(file, context.temp_allocator)
	if read_err != os.ERROR_NONE {
		return read_err
	}

	fields := strings.fields(string(data[:]))
	defer delete(fields)

	for field, idx in fields {
		switch field {
		case "MemTotal:":
			total, _ := strconv.parse_f64(fields[idx + 1])
			memory.total = total / 1024 / 1024
		case "MemAvailable:":
			available, _ := strconv.parse_f64(fields[idx + 1])
			memory.available = available / 1024 / 1024
		}
	}

	memory.used = memory.total - memory.available
	memory.used_percent = (memory.used / memory.total) * 100

	return nil
}

get_memory_info :: proc() -> string {
	meminfo: Memory
	err := get_meminfo(&meminfo)
	if err != nil {
		fmt.eprintfln("Failed to get memory info: %v", err)
	}

	return fmt.tprintf(
		"%.2f GiB / %.2f GiB ({}%0.f%%{})",
		meminfo.used,
		meminfo.total,
		colors.CYAN,
		meminfo.used_percent,
		colors.RESET,
	)
}
