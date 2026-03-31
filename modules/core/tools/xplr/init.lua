-- xplr preview pane configuration for Ghostty + NixOS.
--
-- This keeps the config additive (overriding only required pieces) as
-- recommended by xplr docs, while delegating heavy preview logic to a script.

local xplr = xplr

xplr.fn.custom.preview_pane = xplr.fn.custom.preview_pane or {}

local preview_cache = {
  key = nil,
  body = "",
  title = { format = "preview" },
}

-- Bump this when renderer behavior changes to force cache refresh.
local preview_renderer_rev = "symbols-hq-v4"

local last_log_key = nil

local function strip_ansi(s)
  local out = tostring(s or "")
  out = out:gsub("\27%[[0-9;?]*[%a]", "")
  out = out:gsub("\27%].-\7", "")
  return out
end

local function push_log(message, is_error)
  local xplr_bin = os.getenv("XPLR")
  if not xplr_bin or xplr_bin == "" then
    return
  end

  local msg = strip_ansi(message):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
  if msg == "" then
    return
  end

  local level = "LogSuccess: "
  if is_error then
    level = "LogError: "
  end

  -- shell_execute avoids shell quoting pitfalls and still emits into xplr logs.
  xplr.util.shell_execute(xplr_bin, { "-m", level .. msg:sub(1, 500) })
end

xplr.fn.custom.preview_pane.render = function(ctx)
  local node = ctx.app.focused_node
  if node and node.canonical then
    node = node.canonical
  end

  local title = { format = "preview" }
  local body = ""

  if node then
    local mime = tostring(node.mime_essence or "")
    local is_visual_preview =
      mime:match("^image/") ~= nil
      or mime:match("^video/") ~= nil
      or mime:match("^audio/") ~= nil

    title = {
      format = node.absolute_path,
      style = xplr.util.lscolor(node.absolute_path),
    }

    local cache_key = string.format(
      "%s::%s::%s::%s::%s",
      node.absolute_path,
      tostring(node.last_modified or ""),
      tostring(ctx.layout_size.width),
      tostring(ctx.layout_size.height),
      preview_renderer_rev
    )
    if preview_cache.key == cache_key then
      body = preview_cache.body
    else
      local preview_script = os.getenv("HOME") .. "/.config/xplr/preview.sh"
      local command = "timeout 4.0s "
        .. xplr.util.shell_quote(preview_script)
        .. " "
        .. xplr.util.shell_quote(node.absolute_path)
        .. " "
        .. tostring(ctx.layout_size.width)
        .. " "
        .. tostring(ctx.layout_size.height)
        .. " 2>&1"

      local pipe = io.popen(command)
      if pipe ~= nil then
        body = pipe:read("*a") or ""
        local ok, reason, code = pipe:close()
        if not ok then
          if reason == "exit" and code == 124 then
            body = body .. "\n[preview timeout: command took too long]"
          else
            body = body .. string.format("\n[preview failed: %s %s]", tostring(reason), tostring(code))
          end
        else
          preview_cache.key = cache_key
          preview_cache.body = body
          preview_cache.title = title
        end
      end

      if pipe == nil then
        body = "preview unavailable"
      end

      -- Keep the panel responsive by trimming giant textual output. Visual
      -- previews are allowed to use more payload so image detail is preserved.
      local max_chars = 24000
      if (not is_visual_preview) and #body > max_chars then
        body = body:sub(1, max_chars) .. "\n\n[truncated preview output]"
      end
    end

    local summary
    if is_visual_preview then
      summary = "preview: media rendered"
    else
      local cleaned = strip_ansi(body)
      local first = cleaned:match("([^\n]+)") or ""
      local second = cleaned:match("[^\n]*\n([^\n]+)") or ""
      summary = (first .. " | " .. second):gsub("%s+$", "")
    end

    local log_key = cache_key .. "::" .. summary
    if log_key ~= last_log_key then
      push_log(summary, body:find("%[preview failed", 1, true) ~= nil)
      last_log_key = log_key
    end
  end

  return {
    CustomParagraph = {
      ui = { title = title },
      body = body,
    },
  }
end

local preview_pane = {
  Dynamic = "custom.preview_pane.render",
}

local split_preview = {
  Horizontal = {
    config = {
      constraints = {
        { Percentage = 55 },
        { Percentage = 45 },
      },
    },
    splits = {
      "Table",
      preview_pane,
    },
  },
}

xplr.config.layouts.builtin.default = xplr.util.layout_replace(
  xplr.config.layouts.builtin.default,
  "Table",
  split_preview
)

-- The builtin default layout is a top-level Horizontal split where the
-- right column contains Selection + HelpMenu. Narrow that right column so the
-- main browsing area (table + preview) gets more width.
if xplr.config.layouts.builtin.default.Horizontal
  and xplr.config.layouts.builtin.default.Horizontal.config
then
  xplr.config.layouts.builtin.default.Horizontal.config.constraints = {
    { Percentage = 85 },
    { Percentage = 15 },
  }
end

-- Open high-resolution images externally with nsxiv (matches ranger workflow).
xplr.config.modes.builtin.default.key_bindings.on_key.i = {
  help = "open image in nsxiv",
  messages = {
    {
      BashExecSilently0 = [===[
        if [ -z "${XPLR_FOCUS_PATH:-}" ]; then
          "$XPLR" -m 'LogError: %q' "No focused path"
          exit 0
        fi

        MIME=$(file --dereference --brief --mime-type -- "${XPLR_FOCUS_PATH:?}" 2>/dev/null || true)
        if printf '%s' "$MIME" | grep -q '^image/'; then
          "$HOME/.config/ranger/rifle_nsxiv.sh" -- "${XPLR_FOCUS_PATH:?}" >/dev/null 2>&1 &
          "$XPLR" -m 'LogSuccess: %q' "Opened image in nsxiv"
        else
          "$XPLR" -m 'LogError: %q' "Focused item is not an image"
        fi
      ]===],
    },
  },
}
