# vorp_core

`vorp_core` is the base framework layer for RedM servers running VORP.

It provides the shared player session logic, character state handling, jobs, groups, callbacks, notifications, commands, and core exports that other VORP resources build on top of.

If your server uses multiple VORP resources, this is one of the main resources that needs to be loaded correctly first.

> [!NOTE]
> This repository is the framework layer, not a complete gameplay pack by itself. Resources such as inventory, housing, hunting, crafting, and character systems are expected to run around it.

## Dependencies

`vorp_core` requires these resources to be available:

- `oxmysql`
- `spawnmanager`
- `vorp_menu`

## Installation

1. Place `vorp_core` in your server resources folder.
2. Make sure the required dependencies are started before it.
3. Add `ensure vorp_core` to your server config.
4. Start dependent VORP resources such as `vorp_character` and `vorp_inventory` after `vorp_core`.
5. Review the config files before going live:
   `config/config.lua`, `config/commands.lua`, `config/logs.lua`, and `translation/language.lua`.

A typical load order looks like this:

```cfg
ensure oxmysql
ensure spawnmanager
ensure vorp_menu
ensure vorp_core
```

## Configuration

> [!WARNING]
> Configuring `vorp_core` can take time. Read the configuration files carefully and adapt them to your server before going live. The default setup is not meant to match every server out of the box.

For full configuration details and API usage, use the official docs:

- [VORP Documentation](https://docs.vorp-core.com/introduction)

## Common Setup Mistakes

The most common issues are usually these:

- missing `oxmysql` or starting it after `vorp_core`
- starting `vorp_menu` after `vorp_core`
- changing the folder name instead of keeping it as `vorp_core`
- placing dependent resources before `vorp_core` in the load order
- expecting `vorp_core` alone to replace the rest of the VORP stack
- leaving development-oriented settings enabled in production without reviewing the config first

> [!IMPORTANT]
> If the framework starts but other VORP resources fail to load correctly, check resource order before changing code. In most cases the issue is a missing dependency or a bad start sequence.

## Support

If you run into an issue:

- if you know your way around the code, feel free to open a PR
- if not, open an issue on GitHub
- or join the VORP Discord: [discord.gg/DHGVAbCj7N](https://discord.gg/DHGVAbCj7N)
