function ytdl -d 'Nicer yt-dlp for downloading single video.'

    set --function VideoSpec "$argv[1]"

    command @yt_dlp@ \
        -S ext:mp4:m4a \
        --split-chapters \
        --output '%(fulltitle)s.%(ext)s' \
        "$VideoSpec"

end
