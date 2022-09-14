#!/bin/bash

cd ${function_path}
cargo lambda build --release --arm64
echo "tree"
tree