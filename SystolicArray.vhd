library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.matrix256.all;

entity SystolicArray is
	port( Ain            : in data_array;		--Activation matrix 1D
	      Valid_in_array : in bit_array;  		--tells when inputs can be used
	      Win            : in data_array;		--weight matrix 1D
	      Addin          : in data_array_add; 	--output from above PE to be added to product of Win and Ain
	      CLK            : in std_logic;
	      RESET          : in std_logic;
  	      Aout           : out data_array;		--output of last row
	      Addout         : out data_array_add;	--output of last column
	      Valid_out      : out bit_array		--tells when outputs can be used
		);
end SystolicArray;

Architecture Structure of SystolicArray is


component PE 
generic (
    DW  : integer := 4;
	N   : integer := 4
);
	port(Ain,Win   : in std_logic_vector(DW-1 downto 0);
	     Addin     : in std_logic_vector(DW*2+N- 1 downto 0);
	     CLK       : in std_logic;
	     RESET     : in std_logic;
	     Valid_in  : in std_logic;
	     Aout      : out std_logic_vector(DW- 1 downto 0);
             Addout    : out std_logic_vector(DW*2+N- 1 downto 0);
	     Valid_out : out std_logic
	     );

end component;
  signal Ain_array_nxn : data_array_nxn;
  signal Win_array_nxn : data_array_nxn;
  signal Aout_array_nxn : data_array_nxn;
  signal valid_in_array_nxn : bit_array_nxn;
  signal valid_out_array_nxn : bit_array_nxn;
  signal Addin_array_nxn : data_array_add_nxn;
  signal Addout_array_nxn : data_array_add_nxn;
  
begin

   G1 : for row in 0 to MATRIX_SIZE-1 generate 
          
      G2 : for col in 0 to MATRIX_SIZE-1 generate
	      Col_zero : if (col = 0) generate
		     Ain_array_nxn(row)(col) <= Ain(row);
		     valid_in_array_nxn(row)(col) <= valid_in_array(row);
		  end generate  Col_zero;
		  Col_gr_0 : if (col > 0) generate
		     Ain_array_nxn(row)(col) <= Aout_array_nxn(row)(col-1);
		     valid_in_array_nxn(row)(col) <= valid_out_array_nxn(row)(col-1);
		  end generate  Col_gr_0;
		  col_last : if(col = MATRIX_SIZE-1) generate
		     Aout(row) <= Aout_array_nxn(row)(col);
		     valid_out(row) <= valid_out_array_nxn(row)(col);		 
		  end generate  col_last;	 
		  
		  Row_zero : if (row = 0) generate
    		  Addin_array_nxn(row)(col) <= Addin(col);
		  end generate;
   		  Row_gr_0 : if (row > 0) generate
    		  Addin_array_nxn(row)(col) <= Addout_array_nxn(row-1)(col);
		  end generate;
		  Row_last : if(row = MATRIX_SIZE-1) generate
		     Addout(col) <= Addout_array_nxn(row)(col);
		  end generate  Row_last;
		  
	     
	      
          PE_ij : PE 
          generic map (
            DW  => DATA_WIDTH,
	        N   => LOG2MS
	      )
	      port map (
	            Ain      => Ain_array_nxn(row)(col),
		    Win      => Win(col),
	            Addin    => Addin_array_nxn(row)(col),
	            CLK      => CLK,
		    RESET    => RESET,
		    Valid_in => valid_in_array_nxn(row)(col),
	            Aout     => Aout_array_nxn(row)(col),
	            Addout   => Addout_array_nxn(row)(col),
		    Valid_out => valid_out_array_nxn(row)(col)
		  );
		  
	   end generate;
	end generate;




end Structure;