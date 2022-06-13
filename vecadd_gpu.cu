// Based on https://www.olcf.ornl.gov/tutorials/cuda-vector-addition/
#include "mpi.h"
#include "math.h"
#include "stdio.h"
#include "stdlib.h"

extern int DATA_DISTRIBUTE;
extern int DATA_COLLECT;

// CUDA kernel. Each thread takes care of one element of c
__global__ void gpu_vecadd(float *a, float *b, float *c, int n)
{
  // Get our global thread ID
  int id = blockIdx.x*blockDim.x+threadIdx.x;
 
  // Make sure we do not go out of bounds
  if (id < n)
    c[id] = a[id] + b[id];
}

void compute_node_gpu(unsigned int vector_size ) 
{
  int np;
  unsigned int num_bytes = vector_size * sizeof(float);
  float *input_a, *input_b, *output;
  MPI_Status status;
  MPI_Comm_size(MPI_COMM_WORLD, &np);
  int server_process = np - 1;

  // This process id
  int rank = -1;
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);

  // Name the input and output vectors

  // Device (GPU) input vectors
  float *gpu_input_a;
  float *gpu_input_b;
  
  //Device output vector
  float *gpu_output;

  // Allocate memory	

  // Allocate memory for each vector on host
  input_a = (float*)malloc(num_bytes);
  input_b = (float*)malloc(num_bytes);
  output = (float*)malloc(num_bytes);
 
  // Allocate memory for each vector on the GPU
  cudaMalloc(&gpu_input_a, num_bytes);
  cudaMalloc(&gpu_input_b, num_bytes);
  cudaMalloc(&gpu_output, num_bytes);

  /* Get the input data from data server process */
  MPI_Recv(input_a, vector_size, MPI_FLOAT, server_process, DATA_DISTRIBUTE, MPI_COMM_WORLD, &status);

  MPI_Recv(input_b, vector_size, MPI_FLOAT, server_process, DATA_DISTRIBUTE, MPI_COMM_WORLD, &status);

  /* Compute the partial vector addition */

  // Copy host vectors to device
  cudaMemcpy( gpu_input_a, input_a, num_bytes, cudaMemcpyHostToDevice);
  cudaMemcpy( gpu_input_b, input_b, num_bytes, cudaMemcpyHostToDevice);
 
  int block_size, grid_size;
 
  // Number of threads in each thread block
  block_size = 1024;
 
  // Number of thread blocks in grid
  grid_size = (int)ceil((float)vector_size/block_size);
 
  // Execute the kernel
  gpu_vecadd<<<grid_size, block_size>>>(gpu_input_a, gpu_input_b, gpu_output, vector_size);

  // Copy array back to host
  cudaMemcpy( output, gpu_output, num_bytes, cudaMemcpyDeviceToHost );

  // Signal that computation is done
  printf("ComputeNode (%d): GPU partial vector addition complete.\n", rank);
  fflush(stdout);

  // Check GPU calculation against CPU version for debugging
  // Add vectors using CPU
  float *cpu_output = (float *)malloc(num_bytes);
  for(int i = 0; i < vector_size; i++) 
    cpu_output[i] = input_a[i] + input_b[i];

  float error = 0;
  float total = 0;
  for(int i = 0; i < vector_size; i++)
    {
      total = total + cpu_output[i];
      error = error + abs(cpu_output[i] - output[i]);
    }

  printf("ComputeNode (%d): GPU result differs from CPU result by %f%%.\n", rank, 100.0*error/total);
  fflush(stdout);

  printf("ComputeNode (%d): CPU result (first 10 elements):\n", rank);
  for(int i = 0; i < 10; i++)
      printf("%f ", cpu_output[i]);
  printf("\n");
  fflush(stdout);	 

  printf("ComputeNode (%d): GPU result (first 10 elements):\n", rank);
  for(int i = 0; i < 10; i++)
      printf("%f ", output[i]);
  printf("\n");
  fflush(stdout);	 

  MPI_Barrier(MPI_COMM_WORLD);

  // Send the output to the data server
  MPI_Send(output, vector_size, MPI_FLOAT, server_process, DATA_COLLECT, MPI_COMM_WORLD);

  // Clean up memory

  // Release device memory
  cudaFree(gpu_input_a);
  cudaFree(gpu_input_b);
  cudaFree(gpu_output);
 
  // Release host memory
  free(input_a);
  free(input_b);
  free(output);
  free(cpu_output); 
}
