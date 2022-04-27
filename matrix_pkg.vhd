library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


package matrix256 is
    	constant DATA_WIDTH  :  integer := 8; -- Always same
	constant MATRIX_SIZE :  integer := 4; -- Matrix size
	constant LOG2MS      :  integer := 2;  -- Log2(Matrix size)
	constant ADDR_SIZE   :  integer := LOG2MS;
	constant MEM_DEPTH   :  integer := MATRIX_SIZE;
	
	type data_array is array ( 0 to MATRIX_SIZE-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
	
	type data_array_nxn is array (0 to MATRIX_SIZE-1) of data_array;
	
	type bit_array is array (0 to MATRIX_SIZE-1) of  std_logic;
	type bit_array_nxn is array (0 to MATRIX_SIZE-1) of bit_array;  
	
	
	
    	type data_array_add is array ( 0 to MATRIX_SIZE-1) of std_logic_vector(DATA_WIDTH*2+LOG2MS-1 downto 0);
	
	type data_array_add_nxn is array (0 to MATRIX_SIZE-1) of data_array_add;
	
	type address_array is array ( 0 to MATRIX_SIZE-1) of std_logic_vector(ADDR_SIZE-1 downto 0);
	
	type mem is array ( 0 to MEM_DEPTH-1 ) of std_logic_vector(DATA_WIDTH-1 downto 0);
	type mem_array is array (0 to MATRIX_SIZE-1) of mem;
	
	type mem_out is array ( 0 to MEM_DEPTH-1 ) of std_logic_vector(DATA_WIDTH*2+LOG2MS-1 downto 0);
	type mem_out_array is array (0 to MATRIX_SIZE-1) of mem_out;

	
end package matrix256;