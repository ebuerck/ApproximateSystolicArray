
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.matrix256.all;


entity matrix_top is
  Port ( CLK             : in std_logic;
	 reset           : in std_logic;
         valid_in        : in std_logic;  -- Valid in high when valid AIn and Win is there
         load_new_data   : out std_logic;  -- Load new data indication from FSM to Testbench
         Ain             : in data_array;  -- Ain Row from testbench to MEM
         Win             : in data_array;  -- WIn Row from Testbench  to MEM
         result_rdy      : out std_logic; -- Result ready when Atleast 1 Yout Row is ready in DOne state
	 read_result     : in std_logic;  --  Read result is from testbench seeing the Result ready 
	 valid_out       : out std_logic;  -- Valid out to testbecnh telling valid Yout is there on the bus
	 Yout            : out data_array_add  -- Yout Row result of Matrix multiplication
  
  );
end matrix_top;

architecture Behavioral of matrix_top is

  component FSM 
	port(CLK            	    : in std_logic;
	     reset           	    : in std_logic;
             valid_in        	    : in std_logic;
             load_new_data   	    : out std_logic;	     
	     valid_in_shifted	    : out bit_array;
	     clear_PE       	    : out std_logic;
	     result_rdy     	    : out std_logic;
	     read_result     	    : in std_logic;
	     valid_out       	    : out std_logic;
	     write_en        	    : out std_logic;
	     write_address   	    : out std_logic_vector(ADDR_SIZE-1 downto 0);
	     read_out_mem	    : out std_logic;
	     read_address_out_mem   : out std_logic_vector(ADDR_SIZE-1 downto 0)
    );
  end component;
    
  component AddrsSelect 
  Port ( clk 			: in std_logic;
         reset 			: in std_logic;
         write_en 		: in std_logic;
         write_address   	: in std_logic_vector(ADDR_SIZE-1 downto 0);
         read_out_mem           : in std_logic;
	 read_address_out_mem   : in std_logic_vector(ADDR_SIZE-1 downto 0);
         Ain             	: in data_array;
         Win             	: in data_array;
         read_en        	: in bit_array;
         Ain_shifted     	: out data_array;
         Win_shifted     	: out data_array;     
         valid_in_addout 	: in bit_array;
         Addout_in       	: in data_array_add;   
         Yout            	: out data_array_add
   ); 
   end component;
   
   component SystolicArray 
	port( Ain            : in data_array;
	      Valid_in_array : in bit_array;  
	      Win            : in data_array;
	      Addin          : in data_array_add; 
	      CLK            : in std_logic;
	      RESET          : in std_logic;
	      Aout           : out data_array;
	      Addout         : out data_array_add;
	      Valid_out      : out bit_array
		);
 end component;
 signal valid_in_shifted: bit_array;
 signal	clear_PE        	: std_logic;
 signal write_en        	: std_logic;
 signal write_address   	: std_logic_vector(ADDR_SIZE-1 downto 0);
 signal read_out_mem        	: std_logic;
 signal read_address_out_mem   	: std_logic_vector(ADDR_SIZE-1 downto 0);
 signal Ain_shifted  		:  data_array;
 signal Win_shifted  		:  data_array;
 signal read_en      		: std_logic;
 signal Addin        		: data_array_add;
 signal Addout      		: data_array_add;
 signal valid_out_sys 		: bit_array;
begin

    FSM_i : FSM port map
        (CLK             	=> CLK,
	 reset           	=> reset,
         valid_in         	=> valid_in,
         load_new_data    	=> load_new_data,	     
	 valid_in_shifted 	=> valid_in_shifted,
	 clear_PE         	=> clear_PE,
	 result_rdy       	=> result_rdy,
	 read_result      	=> read_result,
	 valid_out        	=> valid_out,
	 write_en         	=> write_en,
	 write_address    	=> write_address,
	 read_out_mem     	=> read_out_mem,
	 read_address_out_mem  	=> read_address_out_mem
    );
    
  AddrsSelect_i :  AddrsSelect Port map
       ( clk            	=> CLK,
         reset          	=> reset,
         write_en       	=> write_en,
         write_address  	=> write_address,
         read_out_mem   	=> read_out_mem,
	 read_address_out_mem 	=> read_address_out_mem,
         Ain            	=> Ain,
         Win            	=> Win, 
         read_en        	=> valid_in_shifted,
         Ain_shifted    	=> Ain_shifted,
         Win_shifted    	=> Win_shifted, 
         valid_in_addout 	=> valid_out_sys,
         Addout_in       	=> Addout,
         Yout           	=> Yout          
       ); 
   
   Addin <=  (others=>(others => '0'));
   
   SystolicArray_i : SystolicArray port map
        ( Ain          	 => Ain_shifted,
	  Valid_in_array => valid_in_shifted,  
	  Win          	 => Win_shifted,
	  Addin          => Addin,
	  CLK            => clk,
	  RESET          => reset,
	  Aout           => open,
	  Addout         => Addout,
	  Valid_out      => valid_out_sys
	);

end Behavioral;
