CXX = g++
CUDA_NVCC = nvcc
CXXFLAGS = -std=c++14 -I./include
CUDAFLAGS = -arch=sm_86 -I./include -Xcompiler -fPIC

INCLUDES = $(wildcard ./include/*.hpp) $(wildcard ./include/*.cuh)
SOURCES = ./src/cuda_gemm_utils.cu \
          ./src/00_non_coalesced_global_memory_access.cu \
          ./src/01_coalesced_global_memory_access.cu \
          ./src/02_2d_block_tiling.cu \
          ./src/02_2d_block_tiling_vectorized_memory_access.cu \
          ./src/03_2d_block_tiling_1d_thread_tiling.cu \
          ./src/03_2d_block_tiling_1d_thread_tiling_vectorized_memory_access.cu \
          ./src/04_2d_block_tiling_2d_thread_tiling.cu \
          ./src/04_2d_block_tiling_2d_thread_tiling_vectorized_memory_access.cu \
          ./src/05_2d_block_tiling_2d_thread_tiling_matrix_transpose.cu \
          ./src/05_2d_block_tiling_2d_thread_tiling_matrix_transpose_vectorized_memory_access.cu \
          ./src/06_2d_block_tiling_2d_warp_tiling_2d_thread_tiling_matrix_transpose.cu \
          ./src/06_2d_block_tiling_2d_warp_tiling_2d_thread_tiling_matrix_transpose_vectorized_memory_access.cu \
          ./src/07_2d_block_tiling_2d_warp_tiling_2d_thread_tiling_matrix_transpose_wmma.cu \
          ./src/07_2d_block_tiling_2d_warp_tiling_2d_thread_tiling_matrix_transpose_wmma_vectorized_memory_access.cu

BUILD_DIR = build
OBJECTS = $(patsubst ./src/%.cu,$(BUILD_DIR)/%.o,$(SOURCES))

all: $(BUILD_DIR)/profile_cuda_gemm_fp32 $(BUILD_DIR)/profile_cuda_gemm_fp16

$(BUILD_DIR)/%.o: ./src/%.cu
	$(CUDA_NVCC) $(CUDAFLAGS) -c -o $@ $<

$(BUILD_DIR)/profile_cuda_gemm_fp32.o: ./src/profile_cuda_gemm_fp32.cu
	$(CUDA_NVCC) $(CUDAFLAGS) -c -o $@ $<

$(BUILD_DIR)/profile_cuda_gemm_fp16.o: ./src/profile_cuda_gemm_fp16.cu
	$(CUDA_NVCC) $(CUDAFLAGS) -c -o $@ $<

$(BUILD_DIR)/profile_cuda_gemm_fp32: $(BUILD_DIR)/profile_cuda_gemm_fp32.o $(filter-out $(BUILD_DIR)/profile_cuda_gemm_fp16.o, $(OBJECTS))
	$(CUDA_NVCC) $(CUDAFLAGS) -o $@ $^ -lcublas

$(BUILD_DIR)/profile_cuda_gemm_fp16: $(BUILD_DIR)/profile_cuda_gemm_fp16.o $(filter-out $(BUILD_DIR)/profile_cuda_gemm_fp32.o, $(OBJECTS))
	$(CUDA_NVCC) $(CUDAFLAGS) -o $@ $^ -lcublas

profile_fp16: $(BUILD_DIR)/profile_cuda_gemm_fp16
	$(BUILD_DIR)/profile_cuda_gemm_fp16

profile_fp32: $(BUILD_DIR)/profile_cuda_gemm_fp32
	$(BUILD_DIR)/profile_cuda_gemm_fp32

clean:
	rm -rf $(BUILD_DIR)/*

.PHONY: all clean install
