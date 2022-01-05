#!/bin/sh
set -e

# This script downloads the binaries for the most recent version of TabNine.

version="$(curl -sS https://update.tabnine.com/bundles/version)"
targets='i686-pc-windows-gnu
    x86_64-apple-darwin
    aarch64-apple-darwin
    x86_64-pc-windows-gnu
    x86_64-unknown-linux-musl'

rm -rf ./binaries

echo "$targets" | while read target
do
    mkdir -p binaries/$version/$target
    path=$version/$target
    echo "downloading $path"
    curl -sS https://update.tabnine.com/bundles/$path/TabNine.zip > binaries/$path/TabNine.zip
    unzip -o binaries/$path/TabNine.zip -d binaries/$path
    rm binaries/$path/TabNine.zip
    chmod +x binaries/$path/*
done
