You can compile and run this code from the respository directory on (for example) the CARC Xena cluster with:

module load cuda/11.5.0-qzxk
module load openmpi/4.1.2-h55j
make

and run it with:

srun --partition debug --ntasks 4 --gpus=1 vecadd_mpi_gpu --gpus

The argument --gpus enables GPU support and --nogpus disables it.
