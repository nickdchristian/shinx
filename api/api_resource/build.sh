#!/bin/bash

cd ${function_path}
cargo lambda build --release --arm64 --output-format zip