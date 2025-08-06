# ICE_NVDLA
# NVDLA Meta-Simulation Automation

This update simplifies the entire NVDLA meta-simulation workflow with run_nvdla_metasimulation.sh

The script automates the following steps:
* Compiles the selected workload (e.g., AlexNet, ResNet50, etc.) using the specified configtarget and cprecision
* Runs marshal -v build and marshal -v install with the appropriate workload configuration
* Launches the meta-simulation

# Key Files and Location

1. run_nvdla_metasimulation.sh, This script should be placed in the root of the riscv-performance-characterization directory
2. Updated Compile Scripts (under nvdla-workload/models): run_alexnet_nvdla_compile.sh, run_resnet50_nvdla_compile.sh, etc. These scripts were modified to support flexible configtarget and cprecision inputs

The workload config file must in nvdla-SIZE-MODEL_NAME.json format, and the compiling script must in run_MODEL_NAME_nvdla_compile.sh format for flexible use

# Usage

From /riscv-performance-characterization directory, run: bash run_nvdla_metasimulation.sh [model_name] [configtarget] [cprecision]