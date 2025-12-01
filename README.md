# systema

![](vhs/systema.gif)

> Systema - System + "ma" (latin for "from") - getting info from system

A fast and lightweight system information fetch tool written in Zig.

## Features

- **Fast & Lightweight**: Built with Zig for high performance.
- **System Information**: Displays key system details:
    - Username @ Hostname
    - System / OS
    - Kernel version
    - Desktop Environment
    - CPU information
    - Shell
    - Uptime
    - Memory usage
    - Storage usage (Root partition)
    - Terminal Colors
- **Customization**:
    - Custom ASCII logo support (embedded or from file)
    - Configurable colors for logo, icons, and labels
    - Adjustable layout (logo usage, gaps)

## Prerequisites

- **Zig**: Version 0.15.2 or later
- **Linux**: Currently supports Linux systems (LibC required)

## Installation

### Building from source

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/systema.git
   cd systema
   ```

2. Build deeply optimized release:
   ```bash
   zig build -Doptimize=ReleaseFast
   ```

3. Run the binary:
   ```bash
   ./zig-out/bin/systema
   ```

### Via Nix

The project includes a `flake.nix` for Nix users.

```bash
nix build
./result/bin/systema
```

or run directly:

```bash
nix run
```

### Via Nix flake

Add the following to your `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systema.url = "github:alvaro17f/systema";
  };

  outputs = { self, nixpkgs, systema, ... }: {
    nixosConfigurations.yourhostname = nixpkgs.lib.nixosSystem {
      modules = [
        {
          environment.systemPackages = [
            systema.packages.${pkgs.system}.default
          ];
        }
      ];
    };
  };
}
```

## Usage

```bash
systema [options]
```

### Options

| Flag | Description |
|------|-------------|
| `-h`, `--help` | Print help message and exit |
| `-v`, `--version` | Print version information |
| `--logo-path=<path>` | Path to a custom ASCII logo file |
| `--logo-gap=<number>` | Set gap between logo and information (default: 3) |
| `--logo-color=<color>` | Set the color of the logo |
| `--icons-color=<color>` | Set the color of the icons |
| `--labels-color=<color>` | Set the color of the labels |

