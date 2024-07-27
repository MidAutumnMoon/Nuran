{ lib, pkgs, }: ''

function ytdl -d 'yt-dlp config for reasonable balance between quality and size'

    set --function VideoSpec "$argv[1]"

    command '${lib.getExe pkgs.yt-dlp}' \
        --no-playlist \
        -S "quality:res,hdr,codec:av1" \
        -f "bestvideo[height<=1080]+bestaudio/best" \
        --add-metadata \
        --embed-chapters \
        --embed-thumbnail \
        --embed-metadata \
        --embed-subs \
        --sub-langs 'all' \
        --ppa "EmbedSubtitle:-default_mode infer_no_subs" \
        --compat-options "no-live-chat" \
        --mtime \
        --output '%(fulltitle)s.%(ext)s' \
        --merge-output-format "mkv" \
        -- "$VideoSpec"

end

''
