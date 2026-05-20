package models

System :: struct {
	username: string,
	hostname: [65]u8,
	system:   string,
	kernel:   string,
	cpu:      Maybe(string),
	shell:    string,
	uptime:   string,
	desktop:  string,
	memory:   string,
	storage:  string,
	colors:   string,
}
