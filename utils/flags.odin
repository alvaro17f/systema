package utils

import "../colors"
import "../models"
import "core:fmt"
import os "core:os/os2"
import "core:strconv"
import "core:strings"

@(private)
help :: proc(app_name: string) {
	fmt.printfln(
		`
{}*************************************************************
 {}%s{} - Fetch system information with style
{}*************************************************************{}
-d:           Disable logo
-l <path>:    Set the logo path
-c <color>:   Set the logo color by ansi number [default: 36]
-g <gap>:     Set the gap between logo and info [default:  3]
-o <offset>:  Set the info offset vertically    [default:  0]
-h, help:     Display this help message
-v, version:  Display the current version{}
  `,
		colors.BLUE,
		colors.RED,
		strings.to_upper(app_name, context.temp_allocator),
		colors.RESET,
		colors.BLUE,
		colors.YELLOW,
		colors.RESET,
	)
}

@(private)
version :: proc(app_name: string, current_version: string) {
	fmt.printfln(
		"\n%s%s Version: %s%s%s%s",
		colors.YELLOW,
		strings.to_upper(app_name, context.temp_allocator),
		colors.RESET,
		colors.CYAN,
		current_version,
		colors.RESET,
	)
}

flags :: proc(config: ^models.Config) {
	arguments := os.args[1:]

	for argument, idx in arguments {
		switch (argument) {
		case "-h", "help":
			help(config.name)
			os.exit(0)
		case "-v", "version":
			version(config.name, config.version)
			os.exit(0)
		case "-d":
			config.logo = false
		case "-l":
			config.logo_path = arguments[idx + 1]
		case "-c":
			color := (arguments[idx + 1])
			config.logo_color = fmt.tprintf("\033[{}m", color)
		case "-g":
			index := len(arguments) > idx + 1 ? idx + 1 : 0
			gap, _ := strconv.parse_int(arguments[index], 10)
			config.logo_gap = gap
		case "-o":
			index := len(arguments) > idx + 1 ? idx + 1 : 0
			offset, _ := strconv.parse_int(arguments[index], 10)
			config.info_offset = offset
		}
	}
}
