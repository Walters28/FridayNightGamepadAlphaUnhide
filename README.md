# Friday Night Gamepad Unhide

![Friday Night Gamepad Alpha Unhide icon](assets/icon.png)

**By Walters · Version 0.2.0 · All Rights Reserved**

A small, unofficial workaround for the WoW: Forever beta issue where the native Gamepad Action Bar disappears while controller actions still work. It checks the built-in bar once when you enter the world, showing the bar and page frame if they are hidden. A fully transparent frame also has its alpha restored. Changes to protected frames wait until combat ends.

## Install

Copy the `GamepadAlphaUnhide` folder into the active World of Warcraft client's `Interface/AddOns` directory. Enable **Gamepad UI (Alpha)** in game options, enable this addon, then enter the world.

## Commands

| Command | Effect |
| --- | --- |
| `/gpau` | Print visibility, alpha, anchor, and character position override state. |
| `/gpau show` | Retry the visibility check. |
| `/gpau center` | Show the bar and place it at the previously recorded bottom-center anchor for this character. |
| `/gpau clear` | Remove this character's position override and restore the previous anchor captured in the current session. |

The addon touches only the native `GamepadMainActionBarFrame` and its page frame. The optional position override changes only the root bar anchor. It does not change bindings or replace the native controller UI.

## Compatibility

- TOC Interface: `16001`.
- A local test restored a hidden native bar on client `1.60.1.70291`. A later disable/reactivate check also restored the buttons, but that session's exact build was not recorded.
- The installed client reported `1.60.1.70338` on October 11, 2026. Other builds have not been tested.

This is a beta workaround, and an Edit Mode change may hide the bar again. Use `/gpau show` to retry. This project is not affiliated with Blizzard Entertainment.

See [CHANGELOG.md](CHANGELOG.md) and [LICENSE](LICENSE).
