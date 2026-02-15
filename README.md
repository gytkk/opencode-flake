# OpenCode Nix Flake

This repository provides a **Nix flake packaging** of the [OpenCode](https://github.com/anomalyco/opencode)
pre-built binary. It downloads release artifacts from GitHub and exposes the `opencode`
CLI as a first-class Nix package.

## Supported platforms

- `aarch64-darwin`
- `x86_64-darwin`
- `x86_64-linux`
- `aarch64-linux`

## Usage

### Run directly

```bash
nix run github:YOUR_GITHUB_HANDLE/opencode-flake#opencode -- --version
```

### Install into profile

```bash
nix profile install github:YOUR_GITHUB_HANDLE/opencode-flake#opencode
```

### Use in flakes

```nix
{
  inputs = {
    opencode.url = "github:YOUR_GITHUB_HANDLE/opencode-flake";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs, opencode }: {
    packages.x86_64-linux.default = opencode.packages.x86_64-linux.opencode;
  };
}
```

### Use as overlay

```nix
nixpkgs.overlays = [ opencode.overlays.default ];

# then
pkgs.opencode
```

## Files

- `flake.nix` — defines package outputs and package set across all supported systems.
- `package.nix` — fetches each upstream release artifact and defines the derivation.
- `scripts/update.sh` — updates `package.nix` to the latest upstream tag and hashes.
- `.github/workflows/update.yml` — runs the update script on a schedule and commits the result.

## Updating manually

If you need to bump versions by hand:

```bash
./scripts/update.sh
```

The script:

1. Fetches the latest tag from `anomalyco/opencode`.
2. Recomputes SRI hashes for all platforms.
3. Updates `package.nix` in-place.

## Verifying/building

```bash
nix build .#opencode --no-link
```

This command is also used in CI after any generated diff.

## License

MIT (same as upstream project). See `package.nix` metadata for package information.
