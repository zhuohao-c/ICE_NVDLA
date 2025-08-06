#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Usage: $0 <configtarget> <cprecision>"
    echo "Example: $0 nv_small fp16"
    exit 1
fi

CONFIGTARGET="$1"
CPRECISION="$2"

NVDLA_WORKLOAD_DIR=$PWD/..
OUTPUT_DIR=$NVDLA_WORKLOAD_DIR/models/alexnet
COMPILER_PATH=$NVDLA_WORKLOAD_DIR/compiler

export LD_LIBRARY_PATH=$NVDLA_WORKLOAD_DIR/compiler:$LD_LIBRARY_PATH

$COMPILER_PATH/nvdla_compiler \
    --prototxt "$NVDLA_WORKLOAD_DIR/models/alexnet/source/alexnet.prototxt" \
    --caffemodel "$NVDLA_WORKLOAD_DIR/models/alexnet/source/alexnet.caffemodel" \
    --configtarget "$CONFIGTARGET" \
    --informat nchw \
    --cprecision "$CPRECISION" \
    -o "$OUTPUT_DIR"

mv fast-math.nvdla $OUTPUT_DIR/alexnet_small.nvdla