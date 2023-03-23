pushd "$src/usr"

install -Dm755 "bin/yuzu" "$out/bin/yuzu"
cp -rv "share" "$out"
