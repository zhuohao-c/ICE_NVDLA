#include <stdint.h>
#include <stdio.h>
#include "nvdla.h"
#include "mmio.h"
#include <riscv-pk/encoding.h>

#define NVDLA_BASE 0x10040000
#define reg_write(addr,val) reg_write32(NVDLA_BASE+addr,val)
#define reg_read(addr) reg_read32(NVDLA_BASE+addr)

int main(void)
{
    // Set producer pointer
    reg_write(SDP_RDMA_S_POINTER_0, 0);
    reg_write(SDP_S_POINTER_0, 0);
    reg_write(CSC_S_POINTER_0, 0);
    reg_write(CDMA_S_POINTER_0, 0);

    // Configure CONV operation (simplified example)
    reg_write(CSC_D_MISC_CFG_0, 0x0); // precision settings (INT8)
    reg_write(CSC_D_DATAIN_FORMAT_0, 0x0); // input: feature map
    reg_write(CSC_D_DATAIN_SIZE_EXT_0_0, 0x00000007); // width
    reg_write(CSC_D_DATAIN_SIZE_EXT_1_0, 0x00000007); // height
    reg_write(CSC_D_DATAIN_SIZE_EXT_1_0, 0x1F); // 32 channels

    // Set input data base address
    reg_write(CDMA_D_DAIN_ADDR_LOW_0_0, 0x90000000);
    reg_write(CDMA_D_DAIN_ADDR_HIGH_0_0, 0x0);
    reg_write(CDMA_D_LINE_STRIDE_0, 0x100);       // Stride
    reg_write(CDMA_D_SURF_STRIDE_0, 0x800);

    // Kernel
    reg_write(CDMA_D_WEIGHT_FORMAT_0, 0x0);   
    reg_write(CSC_D_WEIGHT_SIZE_EXT_0_0, 0x00000002); 
    reg_write(CSC_D_WEIGHT_SIZE_EXT_1_0, 0x00000002); 
    reg_write(CDMA_D_ZERO_PADDING_VALUE_0, 0x0);   

    // Start CONV_RDMA and CONV engine
    reg_write(CDMA_D_OP_ENABLE_0, 0x1);
    reg_write(CSC_D_OP_ENABLE_0, 0x1);

    // Cycle count for performance
    uint64_t cycle1 = rdcycle();
    for (volatile int i = 0; i < 32767; i++) {
        if (reg_read(GLB_S_INTR_STATUS_0) != 0)
            break;
    }
    uint64_t cycle2 = rdcycle();
    printf("conv cycle1: %lu, cycle2: %lu, diff: %lu\n", cycle1, cycle2, cycle2 - cycle1);

    return 0;
}
