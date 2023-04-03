function loss-avifenc -d 'AVIF with a bit lower quality'

    set --function InputFileName "$argv[1]"
    set --function DestFileName "$( path change-extension avif "$InputFileName" )"

    command '@cli_avifenc@' \
        --min 0 \
        --max 63 \
        --minalpha 0 \
        --maxalpha 63 \
        --depth 8 \
        --yuv 420 \
        --range limited \
        --speed 3 \
        --premultiply \
        -a end-usage=q \
        -a cq-level=18 \
        -a tune=butteraugli \
        -a color:enable-chroma-deltaq=1 \
        -a enable-qm=1 \
        --jobs ( math (nproc) / 2 ) \
        "$InputFileName" "$DestFileName"

end
