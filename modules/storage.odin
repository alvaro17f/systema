package modules

import "../colors"
import "core:fmt"
import "core:sys/posix"


get_storage_info :: proc() -> string {
	vfs: posix.statvfs_t
	posix.statvfs("/", &vfs)

	block_size: u64 = vfs.f_bsize
	total_blocks: u64 = auto_cast vfs.f_blocks
	available_blocks: u64 = auto_cast vfs.f_bavail

	total_size: f64 = auto_cast block_size * auto_cast total_blocks

	used_size: f64 = total_size - auto_cast (block_size * available_blocks)

	total_size = total_size / (1024 * 1024 * 1024)
	used_size = used_size / (1024 * 1024 * 1024)
	usage := (used_size / total_size) * 100

	return fmt.tprintf(
		"%2.f GiB / %2.f GiB ({}%0.f%%{})",
		used_size,
		total_size,
		colors.CYAN,
		usage,
		colors.RESET,
	)
}
