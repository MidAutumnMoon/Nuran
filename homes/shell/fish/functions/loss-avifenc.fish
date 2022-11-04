function loss-avifenc -d 'AVIF with a bit lower quality'

    command "@heif_enc@" \
        --avif \
        -p chroma=420 \
        -p threads=16 \
        --bit-depth 8 \
        --premultiplied-alpha \
        "$argv[1]"

end
