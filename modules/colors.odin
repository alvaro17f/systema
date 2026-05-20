package modules

import "../colors"
import "core:fmt"


get_colors_info :: proc() -> string {
	return fmt.tprintf(
		"{}  {}  {}  {}  {}  {} {}",
		colors.BLUE,
		colors.CYAN,
		colors.GREEN,
		colors.YELLOW,
		colors.RED,
		colors.MAGENTA,
		colors.RESET,
	)
}
