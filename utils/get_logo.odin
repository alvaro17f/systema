package utils

import "core:fmt"
import os "core:os/os2"
import "core:strings"

get_logo :: proc(path: string) -> [dynamic]string {
	logo: []u8

	if path == "" {
		logo = #load("../assets/logo.asc")
	} else {
		file, file_err := os.open(path)
		defer os.close(file)
		if file_err != os.ERROR_NONE {
			fmt.eprintfln("Failed to open logo file at %s: %s", path, file_err)
		}

		read_err: os.Error
		logo, read_err = os.read_entire_file_from_file(file, context.temp_allocator)
		if read_err != os.ERROR_NONE {
			fmt.eprintfln("Failed to read logo: %s", read_err)
		}
	}

	lines := strings.split_lines_after(string(logo), context.temp_allocator)
	dynamic_lines := make_dynamic_array([dynamic]string)


	for &line in lines {
		if strings.contains(line, "\t") {
			replaced, _ := strings.replace_all(line, "\t", " ", context.temp_allocator)
			line = replaced
		}
		if strings.contains(line, "\n") {
			replaced, _ := strings.remove_all(line, "\n", context.temp_allocator)
			line = replaced
		}

		append(&dynamic_lines, line)
	}

	return dynamic_lines
}
