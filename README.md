# Claude Desktop for NixOS

Nix package for the **official [Claude Desktop](https://claude.com/download) Linux beta** (Chat, Cowork, and Claude Code Desktop), repackaged from Anthropic's apt repository at `downloads.claude.ai`.

Auto-updated every 6 hours via GitHub Actions — the apt package index provides version and SHA256, each bump is build-tested before release.

## Installation

### Flake Input (NixOS)

```nix
{
  inputs.claude-desktop-nix.url = "github:tomsch/claude-desktop-nix";

  outputs = { self, nixpkgs, claude-desktop-nix, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      modules = [{
        environment.systemPackages = [
          claude-desktop-nix.packages.x86_64-linux.default
        ];
      }];
    };
  };
}
```

Unfree is allowed inside this flake's package set — consumers need no extra `allowUnfree` configuration when using `packages.*`. When using `overlays.default` instead, add `"claude-desktop"` to your `allowUnfreePredicate`.

## Notes

- Wayland-first: the wrapper sets `--ozone-platform=wayland` plus IME/text-input flags (built for niri; works on other wlroots/KDE/GNOME Wayland sessions).
- `--no-sandbox` is required because Chromium's SUID sandbox cannot work from the Nix store.
- x86_64-linux only (upstream also ships arm64 — PRs welcome).
- Linux beta limitations (no Computer Use, no dictation) are upstream, see [Anthropic's docs](https://code.claude.com/docs/en/desktop-linux).

## Update manually

```bash
./update.sh   # reads version + SHA256 from the apt index, patches package.nix
nix build .#default
```

## License

Nix packaging: MIT. Claude Desktop itself is proprietary software by Anthropic.
