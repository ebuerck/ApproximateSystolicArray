# ApproximateSystolicArray

## It preforms 4x4 Approximate Array Multiplication.

## Inputs
========
- CLK - (Clock for the Multiplier)
- reset - (Reset for the multiplier)
- valid_in - (valid in goes to one when Ain and Win are present)
- Ain - (Input from matrix)
- Win - (Input from matrix)

## Outputs
=========
- load_new_data - (Tells when new data is ready to be read in)
- result_rdy - (Tells when Multiplication is finished)
- read_result - (Says the result is completly outputed)
- valid_out - (Tells output is done)
- Yout - (The output of the multiplier)

## Files Description
====================
- AddrsSelect
  - Formats or shifts data for Systolic Array
- Matrix_pkg
  - Basic Matrix Outline
  - Creates data types for other files
- SysContol
  - Sets up Finite State Machine
- Matrix_top
  - Puts All the files together and gives starting values
- PE
  - Takes the inputs and Preformers the approximate Multipication
    - Uses 8x8MultiLit file
- SystolicArray
  - Creates an Array of PE's and gives Matrices
- TestBench
  - Used to Test and validate results
