package main

import "app"
import "colors"
import "core:fmt"
import "core:mem"
import "models"

name :: "systema"
version :: #config(VERSION, "dev")

config := models.Config {
	name        = name,
	version     = version,
	logo        = true,
	logo_color  = colors.CYAN,
	logo_gap    = 3,
	logo_path   = "",
	info_offset = 0,
}

_main :: proc() {
	defer free_all(context.temp_allocator)

	app.init(&config)
}


main :: proc() {
	when ODIN_DEBUG {
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)

		defer {
			if len(track.allocation_map) > 0 {
				fmt.eprintfln("\n=== %v allocations not freed: ===\n", len(track.allocation_map))
				for _, entry in track.allocation_map {
					fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
				}
			}
			mem.tracking_allocator_destroy(&track)
		}
	}

	_main()
}
