You can compile and run this code from the respository directory on (for example) the CARC Xena cluster with:

```consol
module load cuda/11.5.0-qzxk

module load openmpi/4.1.2-h55j

make
```
and run it with:
```console
srun --partition debug --ntasks 4 --gpus=1 vecadd_mpi_gpu --gpus
```
The argument --gpus enables GPU support and --nogpus disables it.

You should see something like the following:

```console
mfricke@xena:~/VECADD_MPI_CUDA [main]$ module load cuda/11.5.0-qzxk

The following have been reloaded with a version change:
  1) zlib/1.2.11-pkmj => zlib/1.2.11-eelg

mfricke@xena:~/VECADD_MPI_CUDA [main]$ module load openmpi/4.1.2-h55j

The following have been reloaded with a version change:
  1) libiconv/1.16-2u23 => libiconv/1.16-hg7j       3) xz/5.2.5-bpnn => xz/5.2.5-zkni
  2) libxml2/2.9.12-lt4y => libxml2/2.9.10-4xxk     4) zlib/1.2.11-eelg => zlib/1.2.11-lfst

mfricke@xena:~/VECADD_MPI_CUDA $ make
nvcc -arch sm_35 -c vecadd_gpu.cu -o vecadd_gpu.o
nvcc warning : The 'compute_35', 'compute_37', 'compute_50', 'sm_35', 'sm_37' and 'sm_50' architectures are deprecated, and may be removed in a future release (Use -Wno-deprecated-gpu-targets to suppress warning).
mpic++ -c vecadd_mpi.c -o vecadd_mpi.o
mpic++ vecadd_mpi.o vecadd_gpu.o -lcudart -o vecadd_mpi_gpu
/usr/bin/ld: skipping incompatible /usr/lib/libm.so when searching for -lm
/usr/bin/ld: skipping incompatible /usr/lib/libgcc_s.so.1 when searching for libgcc_s.so.1
/usr/bin/ld: skipping incompatible /usr/lib/libpthread.so when searching for -lpthread
/usr/bin/ld: skipping incompatible /usr/lib/libc.so when searching for -lc
/usr/bin/ld: skipping incompatible /usr/lib/libgcc_s.so.1 when searching for libgcc_s.so.1
mfricke@xena:~/VECADD_MPI_CUDA $ srun --partition debug --ntasks 4 --gpus=1 vecadd_mpi_gpu --gpus
srun: Using account 2016199 from ~/.default_slurm_account
srun: job 88244 queued and waiting for resources
srun: job 88244 has been allocated resources
You have been allocated one or more GPUs.
Assigning compute node to rank 1.
Assigning compute node to rank 2.
Assigning data server node to rank 3.
DataServer: Starting with rank 3 and vector of size 1 GB
DataServer (3): filling two input vectors with random floats between 1.000000 and 10.000000...
GPU support set to: true.
Will try to allocate a vector of size 1 GB.
Assigning compute node to rank 0.
DataServer (3): finished generating random vector elements.
DataServer (3): Sending vector of size 89478485 to compute node with id 0.
DataServer (3): Sending vector of size 89478485 to compute node with id 1.
ComputeNode (0): GPU partial vector addition complete.
DataServer (3): Sending vector of size 89478485 to compute node with id 2.
ComputeNode (1): GPU partial vector addition complete.
ComputeNode (2): GPU partial vector addition complete.
ComputeNode (0): GPU result differs from CPU result by 0.000000%.
ComputeNode (0): CPU result (first 10 elements):
17.665661 12.963678 10.159586 14.893675 19.021996 10.121510 5.849079 9.960253 8.049904 9.785071 
ComputeNode (0): GPU result (first 10 elements):
17.665661 12.963678 10.159586 14.893675 19.021996 10.121510 5.849079 9.960253 8.049904 9.785071 
ComputeNode (1): GPU result differs from CPU result by 0.000000%.
ComputeNode (1): CPU result (first 10 elements):
10.465598 12.489795 12.471068 12.888964 16.318844 17.900038 4.853577 7.517663 7.253467 18.628969 
ComputeNode (1): GPU result (first 10 elements):
10.465598 12.489795 12.471068 12.888964 16.318844 17.900038 4.853577 7.517663 7.253467 18.628969 
ComputeNode (2): GPU result differs from CPU result by 0.000000%.
ComputeNode (2): CPU result (first 10 elements):
16.699959 14.411093 8.720871 11.177086 6.858014 13.668623 4.602560 11.303101 10.967355 16.542950 
ComputeNode (2): GPU result (first 10 elements):
16.699959 14.411093 8.720871 11.177086 6.858014 13.668623 4.602560 11.303101 10.967355 16.542950 
DataServer (3): All compute nodes finished. Receiving partial results.
DataServer (3): Comparing parallel computation to serial computation...
DataServer (3): Performing serial computation...
DataServer (3): Comparing results...
DataServer (3): Error is 0.000002%.
DataServer (3): MPI result (first 10 elements):
17.665661 12.963678 10.159586 14.893675 19.021996 10.121510 5.849079 9.960253 8.049904 9.785071 
DataServer (3): serial result (first 10 elements):
17.665661 12.963678 10.159586 14.893675 19.021996 10.121510 5.849079 9.960253 8.049904 9.785071 
mfricke@xena:~/VECADD_MPI_CUDA $ 
```
