# Ranger Preview Pipeline And Fixes (Ghostty + Ranger)

## Why This Document Exists

The current setup successfully generates composite preview images with `preview_composite.sh`, but those images are not shown in ranger's preview pane.

This document provides:

1. A full overview of what exists in `modules/core/tools/ranger/`.
2. The end-to-end ranger preview pipeline from file selection to final render.
3. Root-cause analysis of why generated composite images are not displayed.
4. Top 3 ranked solutions (highest probability first) with concrete implementation steps.

## Quick Root Cause Summary

Two independent blockers are present right now:

1. `preview_images = false` in `modules/core/tools/ranger/default.nix` disables ranger's image rendering path.
2. `scope.sh` currently returns text (`exit 5`) for `image/*`, `video/*`, and `audio/*` branches, and never writes a final preview image to `$IMAGE_CACHE_PATH` for ranger to display.

So even when `preview_composite.sh` generates PNG files, ranger is instructed to show text, not images.

## Full Overview Of `modules/core/tools/ranger/`

### `modules/core/tools/ranger/default.nix`

Role:

- Home Manager module for ranger setup, dependencies, and file deployment.

Current behavior:

- Enables ranger.
- Installs many preview dependencies (`imagemagick`, `ffmpegthumbnailer`, `exiftool`, `mediainfo`, etc.).
- Sets `preview_images = false`.
- Sets `use_preview_script = true` and `preview_script = "$HOME/.config/ranger/scope.sh"`.
- Copies `scope.sh`, `preview_composite.sh`, `commands.py`, `commands_full.py`, and `rifle.conf` into `~/.config/ranger/`.

Impact:

- With `preview_images = false`, ranger passes `PV_IMAGE_ENABLED=False` to `scope.sh` and does not enter image render path.

### `modules/core/tools/ranger/scope.sh`

Role:

- Ranger preview script invoked for selected files.

Current behavior relevant to issue:

- Accepts ranger's 5 args: `FILE_PATH`, `PV_WIDTH`, `PV_HEIGHT`, `IMAGE_CACHE_PATH`, `PV_IMAGE_ENABLED`.
- Only calls `handle_image` if `PV_IMAGE_ENABLED == True`.
- For `image/*`, `video/*`, `audio/*`, it generates temporary composite files and cache copies, but prints metadata text and exits `5`.
- For `PV_IMAGE_ENABLED=False`, `handle_image` is skipped entirely; `handle_mime image/*` path returns EXIF text (`exit 5`).

Impact:

- Image display exit codes (`6`/`7`) are not reached for normal image media flow in current config.

### `modules/core/tools/ranger/preview_composite.sh`

Role:

- Builds a composite PNG with thumbnail + metadata text.
- Supports ranger mode and `--preview` interactive mode.

Current behavior:

- Works as a standalone generator.
- Produces valid PNG output when called directly.

Impact:

- Script itself is functioning; integration contract with ranger is the issue.

### `modules/core/tools/ranger/preview_composite.py`

Role:

- Python/Pillow equivalent implementation of composite generation.

Current behavior:

- Exists and works interactively, but is **not wired** in `default.nix` (`home.file` does not install it).

Impact:

- Not part of active runtime path unless invoked manually.

### `modules/core/tools/ranger/commands.py`

Role:

- User command extension file loaded by ranger.

Current behavior:

- Mostly default sample command (`my_edit`), not relevant to preview pipeline.

### `modules/core/tools/ranger/commands_full.py`

Role:

- Reference copy of ranger default command implementations.

Current behavior:

- Header explicitly notes that `commands_full.py` itself is not loaded as active custom commands unless converted to `commands.py` usage pattern.

Impact:

- Helpful as reference, not a preview execution path.

### `modules/core/tools/ranger/rifle.conf`

Role:

- File opener rules (`open` behavior), not preview rendering.

Current behavior:

- Includes `ghostty` terminal entry.

Impact:

- Useful for launching programs, not for preview pane image draw logic.

## End-To-End Ranger Preview Pipeline

This is the exact flow from selecting a file to showing preview.

1. User selects a file in ranger browser UI.
2. Ranger checks if file has preview (`ranger/container/file.py`, `has_preview`).
3. Ranger requests preview source (`File.get_preview_source -> FM.get_preview`).
4. `FM.get_preview` launches preview script with arguments:
   - `preview_script path width height cacheimg preview_images`
   - Code path: `ranger/core/actions.py` (`CommandLoader` args).
5. Ranger waits for script completion and interprets exit code:
   - `0/3/4/5`: treat stdout as text preview.
   - `6`: preview image should be read from `cacheimg` (`$IMAGE_CACHE_PATH`).
   - `7`: preview image is the file itself.
6. If exit code says image (`6`/`7`), ranger sets pager image (`pager.set_image(...)`).
7. Pager calls active image displayer backend (`self.fm.image_displayer.draw(...)`).
8. Image displayer backend is selected from `preview_images_method` (`w3m`, `kitty`, etc.) in `ranger/ext/img_display.py`.
9. If backend succeeds, image appears in preview pane.

## Where It Breaks In Current Setup

### Breakpoint 1: Preview Images Disabled

Current config sets `preview_images = false`.

Consequence:

- Ranger passes `PV_IMAGE_ENABLED=False` into `scope.sh`.
- `scope.sh` does not call `handle_image` at all.
- No chance to return `exit 6`/`7` image codes.

### Breakpoint 2: Text Exit Code In Media Branches

Even if `PV_IMAGE_ENABLED=True`, current `scope.sh` media branches:

- Generate composites in temporary files.
- Copy to `~/.cache/preview_composite/` for reference.
- Print metadata text and `exit 5`.

Consequence:

- Ranger correctly treats preview as text, not image.

### Breakpoint 3: No Final Image Written To `$IMAGE_CACHE_PATH` For Image Display Path

Ranger expects the preview image at `$IMAGE_CACHE_PATH` when `exit 6` is returned.

Current `scope.sh` image/video/audio branches do not leave final output at `$IMAGE_CACHE_PATH` and do not return `6`.

Consequence:

- Even successful composite generation does not satisfy ranger image preview contract.

## External References Used

### Ranger docs/source/examples

1. Ranger default `scope.sh` (official contract and exit codes 6/7):
   - https://github.com/ranger/ranger/blob/master/ranger/data/scope.sh
2. Ranger preview execution path in source (`core/actions.py`, `container/file.py`, `gui/widgets/pager.py`, `ext/img_display.py`):
   - https://github.com/ranger/ranger
3. Ranger PR #3036 (merged): auto-detect kitty protocol support instead of strict TERM allowlist:
   - https://github.com/ranger/ranger/pull/3036
4. Ranger issue #3035 (Ghostty not detected by older logic):
   - https://github.com/ranger/ranger/issues/3035
5. Ranger issue #3203 (newer Ghostty behavior reporting `EINVAL: invalid data`):
   - https://github.com/ranger/ranger/issues/3203

### Ghostty docs/forum/discussions

1. Ghostty features docs (Kitty graphics protocol listed as supported):
   - https://ghostty.org/docs/features
2. Ghostty Sixel support discussion (maintainer stance: no Sixel support):
   - https://github.com/ghostty-org/ghostty/discussions/2496
3. Ghostty discussion involving kitty graphics temporary-file behavior and compatibility details:
   - https://github.com/ghostty-org/ghostty/discussions/5774

## Top 3 Solutions (Ranked)

## 1) Most Reliable: Protocol-Free In-Pane Rendering With `chafa` (Text Mode)

Probability of success: **High**

Why this ranks first:

- Avoids all kitty/sixel/w3m protocol quirks.
- Works in Ghostty because output is plain terminal text (ANSI/Unicode), not terminal image protocol.

What to do:

1. Keep `preview_images = false`.
2. In `scope.sh` media branches, still generate composite PNG.
3. Render composite into preview pane using `chafa` and return `exit 5`.
4. Keep metadata below/above image text render.

Expected outcome:

- You see a visual preview in ranger pane (character-rendered image + metadata), with no dependency on kitty image protocol.

Tradeoff:

- Not pixel-perfect image embedding; text-rendered image quality depends on terminal size and font.

## 2) Native Ranger Image Pipeline: Re-enable Image Path And Return Exit 6

Probability of success: **Medium-High** (depends on Ghostty/ranger protocol compatibility in your exact versions)

Why this ranks second:

- Correctly uses ranger's intended image flow.
- Gives true image pane rendering when terminal protocol negotiation works.

What to do:

1. Set `preview_images = true` in `default.nix` ranger settings.
2. Set `preview_images_method = "kitty"` explicitly.
3. Ensure terminal advertises expected behavior (`TERM` and runtime support); your Ghostty module already sets `term = "xterm-kitty"`.
4. Update `scope.sh` image/video/audio branches to:
   - write composite directly to `$IMAGE_CACHE_PATH`,
   - return `exit 6`,
   - avoid printing metadata text on success path.
5. Only fallback to text (`exit 5`) when composite/image generation fails.

Expected outcome:

- Ranger calls `pager.set_image(cacheimg)` and image displayer renders image in pane.

Tradeoff:

- Sensitive to Ghostty + ranger kitty query compatibility (`OK`/`EBADF` vs `EINVAL`-style responses in some versions).

## 3) Version/Runtime Strategy: Pin Known-Good Pair Or Use A Different Terminal For Ranger

Probability of success: **Medium**

Why this ranks third:

- Effective operationally, but depends on package/version availability and may be less elegant.

What to do:

1. Pin a known-good ranger + Ghostty combination where kitty image query path is stable.
2. If Ghostty remains inconsistent for your target versions, run ranger in kitty/wezterm for media browsing tasks.
3. Continue using your composite generator logic unchanged.

Expected outcome:

- Restores native image rendering by moving to proven protocol environment.

Tradeoff:

- Operational workaround rather than pure in-config fix.

## Recommended Path For Your Current State

Given your current goal (composite previews visible in pane) and evidence from active config:

1. Implement Solution 1 first for immediate, robust in-pane visuals in Ghostty.
2. Implement Solution 2 in a separate branch as "native image mode" and test with your pinned Ghostty/ranger versions.
3. Keep Solution 3 as fallback if protocol behavior regresses again.

## Validation Checklist

Run these checks after implementing any fix:

1. Confirm ranger settings at runtime: `:set preview_images?`, `:set preview_images_method?`, `:set use_preview_script?`.
2. Test script contract directly:
   - `~/.config/ranger/scope.sh /path/to/image.png 80 40 /tmp/ranger_test_cache.jpg True`
3. If using native image path, verify `/tmp/ranger_test_cache.jpg` (or passed cache path) exists and script exits `6`.
4. In ranger, select a media file and verify preview pane behavior.
5. If image protocol path fails, capture and inspect ranger exception (often from `ranger/ext/img_display.py`) to identify terminal reply mismatch.

## Notes On Existing `RANGER_IMAGE_PREVIEW_FIX.md`

Your existing document is useful for historical context, but it currently frames the workaround as final and does not describe ranger's internal preview contract in enough detail for debugging image-display failures.

This file is intended to be the deeper technical reference for implementation and troubleshooting.
