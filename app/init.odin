package app

import "../models"
import "../modules"
import "../utils"

init :: proc(config: ^models.Config) {

	utils.flags(config)

	system := models.System {
		username = modules.get_username(),
		hostname = modules.get_hostname(),
		system   = modules.get_system_info(),
		kernel   = modules.get_kernel_info(),
		cpu      = modules.get_cpu_info(),
		shell    = modules.get_shell_info(),
		memory   = modules.get_memory_info(),
		desktop  = modules.get_desktop_info(),
		uptime   = modules.get_uptime_info(),
		storage  = modules.get_storage_info(),
		colors   = modules.get_colors_info(),
	}


	logo := utils.get_logo(config.logo_path)
	defer delete(logo)

	info: [dynamic]string
	defer delete(info)

	append_elems(
		&info,
		utils.build_username_hostname_line(system, system.username, system.hostname),
		utils.build_info_line("", "System", system.system),
		utils.build_info_line("", "Kernel", system.kernel),
		utils.build_info_line("", "Desktop", system.desktop),
		utils.build_info_line("", "CPU", system.cpu.(string)),
		utils.build_info_line("", "Shell", system.shell),
		utils.build_info_line("", "Uptime", system.uptime),
		utils.build_info_line("", "Memory", system.memory),
		utils.build_info_line("󱥎", "Storage (/)", system.storage),
		utils.build_info_line("", "Colors", system.colors),
	)

	if config.info_offset > 0 {
		utils.add_info_offset(&info, config.info_offset)
	}

	if config.logo {
		utils.print_info_with_logo(config, &logo, &info)
	} else {
		utils.print_info(&info)
	}
}
