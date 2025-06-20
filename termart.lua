local utils = require 'mp.utils'
local msg = require 'mp.msg'

local audio_exts = {
    ".mp3", ".flac", ".wav", ".ogg", ".m4a", ".aac", ".opus", ".alac", ".wma", ".mka"
}

function is_audio_file(path)
    path = string.lower(path or "")
    for _, ext in ipairs(audio_exts) do
        if path:sub(-#ext) == ext then
            return true
        end
    end
    return false
end

function show_album_art(path)
    local tmp_img = "/tmp/mpv_albumart.jpg"

    local extract_cmd = {
        "ffmpeg", "-loglevel", "quiet", "-y", "-i", path, "-an", "-vcodec", "copy", tmp_img
    }
    local result = utils.subprocess({args = extract_cmd})

    if result.status == 0 then
        local chafa_cmd = {"chafa", "--size", "20x20", "--symbols", "all", tmp_img}
        mp.command_native_async({name = "subprocess", args = chafa_cmd, playback_only = false}, function(_) end)
    else
        msg.warn("Album art not found")
    end
end

mp.register_event("file-loaded", function()
    local path = mp.get_property("path")
    if is_audio_file(path) then
        show_album_art(path)
    end
end)
