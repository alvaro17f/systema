package colors

@(private = "package")
ESC :: "\033["

RESET :: ESC + "0m"
BLACK :: ESC + "30m"
RED :: ESC + "31m"
GREEN :: ESC + "32m"
YELLOW :: ESC + "33m"
BLUE :: ESC + "34m"
MAGENTA :: ESC + "35m"
CYAN :: ESC + "36m"
WHITE :: ESC + "37m"

ON_BLACK :: ESC + "40m"
ON_RED :: ESC + "41m"
ON_GREEN :: ESC + "42m"
ON_YELLOW :: ESC + "43m"
ON_BLUE :: ESC + "44m"
ON_MAGENTA :: ESC + "45m"
ON_CYAN :: ESC + "46m"
ON_WHITE :: ESC + "47m"

BRIGHT_BLACK :: ESC + "90m"
BRIGHT_RED :: ESC + "91m"
BRIGHT_GREEN :: ESC + "92m"
BRIGHT_YELLOW :: ESC + "93m"
BRIGHT_BLUE :: ESC + "94m"
BRIGHT_MAGENTA :: ESC + "95m"
BRIGHT_CYAN :: ESC + "96m"
BRIGHT_WHITE :: ESC + "97m"

ON_BRIGHT_BLACK :: ESC + "100m"
ON_BRIGHT_RED :: ESC + "101m"
ON_BRIGHT_GREEN :: ESC + "102m"
ON_BRIGHT_YELLOW :: ESC + "103m"
ON_BRIGHT_BLUE :: ESC + "104m"
ON_BRIGHT_MAGENTA :: ESC + "105m"
ON_BRIGHT_CYAN :: ESC + "106m"
ON_BRIGHT_WHITE :: ESC + "107m"

BOLD :: ESC + "1m"
DIM :: ESC + "2m"
ITALIC :: ESC + "3m"
UNDERLINE :: ESC + "4m"
BLINKING :: ESC + "5m"
INVERSE :: ESC + "7m"
HIDDEN :: ESC + "8m"
STRIKETHROUGH :: ESC + "9m"

BOLD_RESET :: ESC + "22m"
DIM_RESET :: ESC + "22m"
ITALIC_RESET :: ESC + "23m"
UNDERLINE_RESET :: ESC + "24m"
BLINKING_RESET :: ESC + "25m"
INVERSE_RESET :: ESC + "27m"
HIDDEN_RESET :: ESC + "28m"
STRIKETHROUGH_RESET :: ESC + "29m"


Colors :: struct {
	red:       string,
	green:     string,
	yellow:    string,
	blue:      string,
	magenta:   string,
	cyan:      string,
	gray:      string,
	black:     string,
	reset:     string,
	bold:      string,
	underline: string,
}

colors := Colors {
	red       = ESC + "[31m",
	green     = ESC + "[32m",
	yellow    = ESC + "[33m",
	blue      = ESC + "[34m",
	magenta   = ESC + "[35m",
	cyan      = ESC + "[36m",
	gray      = ESC + "[37m",
	black     = ESC + "[30m",
	reset     = ESC + "[0m",
	bold      = ESC + "[1m",
	underline = ESC + "[4m",
}
