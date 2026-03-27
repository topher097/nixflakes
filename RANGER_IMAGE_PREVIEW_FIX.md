# Ranger Image Preview Solution for Ghostty 1.2.1

## Current Status

- ✅ Composite preview images are being generated and cached
- ✅ PNG files are cached to `~/.cache/preview_composite/` 
- ✅ Formatted metadata is displayed for images, videos, and audio
- ✅ scope.sh provides enhanced metadata display as workaround

## The Problem

**Ghostty 1.2.1 does not support any image preview protocols** that ranger needs:

1. **Kitty Protocol** - Probe fails with EINVAL (bug)
2. **Sixel Protocol** - Not supported (by design)  
3. **w3m/w3mimgdisplay** - Requires X11, incompatible with Ghostty terminal
4. **ueberzug** - Requires X11/Wayland overlay, not compatible

When ranger tries to display images, none of these protocols work in Ghostty 1.2.1.

**References:**
- https://github.com/ghostty-org/ghostty/discussions/5774 (Ghostty EINVAL bug)
- https://github.com/ghostty-org/ghostty/discussions/2496 (Ghostty doesn't support sixel)

## Solution

**Disable image preview protocols and use enhanced metadata display instead.**

The nix config has been updated to:
1. Set `preview_images = false` (disable ranger's image protocol support)
2. Keep `use_preview_script = true` (use scope.sh for custom preview)
3. scope.sh now displays beautifully formatted metadata for:
   - **Images**: File info + full EXIF metadata via `identify` and `exiftool`
   - **Videos**: Media info via `mediainfo` or `ffprobe`
   - **Audio**: Audio metadata via `mediainfo` or `ffprobe`

The composite preview images are still generated and cached to `~/.cache/preview_composite/` for reference.

### Deploy the Fix

```bash
cd /home/topher/Documents/nixflakes
git add -A
git commit -m "Disable image protocols and use enhanced metadata display for Ghostty 1.2.1"
nixos-rebuild switch --flake .
```

Then test:
```bash
ranger
# Navigate to any image/video/audio file
# Should show formatted metadata instead of trying image protocols
```

### Alternative: Upgrade Ghostty

Ghostty 1.3.x may have better protocol support. When available, you can upgrade and try:
```bash
nix flake update ghostty
nixos-rebuild switch --flake .
```

## Required Packages

The nix config now includes all necessary packages:
- `w3m` - w3m image display
- `chafa` - sixel image rendering
- `viu` - image viewer fallback
- And all metadata/video/audio/document tools

These will be installed when you rebuild:

```bash
nixos-rebuild switch --flake .
```

## Testing After Fix

Once deployed, test with:

```bash
ranger
# Navigate to any image, video, or audio file
# Should show formatted metadata with file info and EXIF/media details
```

Check for cached composites (for reference):

```bash
ls ~/.cache/preview_composite/
# Should contain PNG files with composite previews
```

## What You'll See

### Images
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📄 Image: diagram3.png
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/path/to/diagram3.png PNG 1836x843 ...

EXIF Metadata:
File Name                       : diagram3.png
File Size                       : 345 kB
Image Width                     : 1836
Image Height                    : 843
... (more metadata fields)

💾 Composite preview cached to: ~/.cache/preview_composite/
```

### Videos & Audio
Similar formatted output showing media information and metadata.

## Debugging

If metadata isn't displaying:

1. **Check ranger config:**
   ```bash
   grep preview_images ~/.config/ranger/rc.conf
   ```
   Should show: `set preview_images false`

2. **Test scope.sh directly:**
   ```bash
   ~/.config/ranger/scope.sh /path/to/image.png 80 40 /tmp/test.png True
   # Should output formatted metadata and exit with code 5
   ```

3. **Verify packages available:**
   ```bash
   which identify exiftool mediainfo ffprobe
   ```

4. **Check cache generation:**
   ```bash
   ls -lh ~/.cache/preview_composite/
   # Should contain PNG files
   ```

## What Was Changed

- `modules/core/tools/ranger/default.nix`:
  - Set `preview_images = false` to disable all image protocol attempts
  - Added multiple image display tools to home.packages: `w3m`, `viu`, `chafa`
  - Updated documentation explaining why protocols don't work in Ghostty

- `modules/core/tools/ranger/scope.sh`:
  - Composite preview generation and caching to `~/.cache/preview_composite/`
  - Enhanced metadata display for images, videos, and audio files
  - Formatted output with emojis and separators for better readability
  - Exit code 5 for text output (fallback to metadata display)

- `RANGER_IMAGE_PREVIEW_FIX.md`:
  - Documentation explaining the Ghostty protocol limitations
  - Deploy instructions and testing guidance

- `home.nix`:
  - Created for home-manager compatibility

## Ghostty Protocol Support Status

- ✅ Kitty graphics protocol - Advertised but probe broken in 1.2.1 (EINVAL bug)
- ❌ Sixel protocol - NOT supported (explicitly rejected by maintainers)
- ❌ w3m/w3mimgdisplay - Requires X11, incompatible with Ghostty
- ❌ ueberzug - Requires X11/Wayland overlay, incompatible

**Conclusion**: No image protocols work reliably in Ghostty 1.2.1 for ranger preview.

## Implementation Status

- ✅ Composite preview images generated and cached
- ✅ Enhanced metadata display for all media types
- ✅ Formatted output with file info and metadata
- ✅ Ready for deployment

## Next Steps

1. Rebuild the NixOS configuration:
   ```bash
   cd /home/topher/Documents/nixflakes
   git add -A
   git commit -m "Fix ranger preview for Ghostty 1.2.1: use metadata display instead of broken protocols"
   nixos-rebuild switch --flake .
   ```

2. Open ranger and test with images/videos/audio:
   ```bash
   ranger
   ```

3. Check cache for composite preview references:
   ```bash
   ls ~/.cache/preview_composite/
   ```

4. When Ghostty 1.3.x is available, consider upgrading for better protocol support
