#!/bin/bash

if [ $# -ne 3 ]; then
    echo "Failed, Usage: $0 [model_name] [configtarget: nv_small|nv_large] [cprecision: fp16|fp8|int8]"
    echo "Example: $0 alexnet nv_small fp16"
    exit 1
fi

MODEL_NAME="$1"
CONFIGTARGET="$2"
CPRECISION="$3"

if [[ "$CONFIGTARGET" == "nv_small" ]]; then
    SIZE="small"
elif [[ "$CONFIGTARGET" == "nv_large" ]]; then
    SIZE="large"
else
    echo "Invalid configtarget: $CONFIGTARGET (expected nv_small or nv_large)"
    exit 1
fi

WORKLOAD_JSON="nvdla-${SIZE}-${MODEL_NAME}.json"
COMPILE_SCRIPT="run_${MODEL_NAME}_nvdla_compile.sh"

ROOT_DIR="$PWD"
WORKLOAD_DIR="$ROOT_DIR/sims/firesim-workloads/nvdla-workload"
WORKLOAD_CONFIG="$WORKLOAD_DIR/marshal-configs/$WORKLOAD_JSON"
WORKLOAD_COMPILE="$WORKLOAD_DIR/models"
FIRESIM_HW_CONFIG="firesim-rocket-singlecore-small-nvdla-no-nic-l2-llc4mb-ddr3"

echo "Selected model: $MODEL_NAME"
echo "configtarget: $CONFIGTARGET"
echo "cprecision: $CPRECISION"
echo "Compiling with script: $COMPILE_SCRIPT"
echo "Workload config file: $WORKLOAD_JSON"

echo "Step 1: Compile Model"
cd "$WORKLOAD_COMPILE" || { echo "Failed to enter workload directory: $WORKLOAD_COMPILE"; exit 1; }

if [[ -f "$COMPILE_SCRIPT" ]]; then
    bash "$COMPILE_SCRIPT" "$CONFIGTARGET" "$CPRECISION"
    echo "Model compilation completed."
else
    echo "Compile script not found: $COMPILE_SCRIPT"
    exit 1
fi

echo "Step 2: Marshal Build"
cd "$ROOT_DIR" || { echo "Failed to enter root directory: $ROOT_DIR"; exit 1; }

if marshal -v build "$WORKLOAD_CONFIG"; then
    echo "Marshal build completed."
else
    echo "Marshal build failed. Exiting..."
    exit 1
fi


echo "Step 3: Marshal Install"
if marshal -v install "$WORKLOAD_CONFIG"; then
    echo "Marshal install completed."
else
    echo "Marshal install failed. Exiting..."
    exit 1
fi


echo "Step 4: Meta-Simulation Run"
if make meta-run HW="$FIRESIM_HW_CONFIG" WORKLOAD="$WORKLOAD_JSON"; then
    echo "Meta-simulation run completed."
else
    echo "Meta-simulation run failed. Exiting..."
    exit 1
fi

echo "Completed"
