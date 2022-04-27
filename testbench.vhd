library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
use std.textio.all;
library work;
use work.matrix256.all;

entity TestBench is
end TestBench;

architecture behave of TestBench is

  component matrix_top 
  Port ( CLK             : in std_logic;
	 reset           : in std_logic;
         valid_in        : in std_logic;
         load_new_data   : out std_logic;
         Ain             : in data_array;
         Win             : in data_array;
         result_rdy      : out std_logic;
	 read_result     : in std_logic;
	 valid_out       : out std_logic;
	 Yout            : out data_array_add  
  
  );
  end component;
 
 signal    CLK             :  std_logic := '0';
 signal	   reset           :  std_logic := '1';
 signal    valid_in        :  std_logic := '0';
 signal    load_new_data   :  std_logic ;
 signal    Ain             :  data_array;
 signal    Win             :  data_array;
 signal    result_rdy      :  std_logic;
 signal	   read_result     :  std_logic := '0';
 signal	   valid_out       :  std_logic;
 signal	   Yout            :  data_array_add; 
 signal    count 	   : std_logic_vector(ADDR_SIZE downto 0);
 signal    count_read      : std_logic_vector(ADDR_SIZE downto 0);
 begin

  clk <= not clk after 5 ns;
  reset <= '0' after 100 ns;


process(clk, reset)
 
        file AMatrixRead		: text open read_mode is "C:\erbwkf\final project\4x4_1.txt";
	file WMatrixRead	    	: text open read_mode is "C:\erbwkf\final project\4x4_2.txt";

    

    variable Arow, Wrow                 : line;
    variable Aelement, Welement		: integer;
 
   begin
      if (reset = '1') then
        count <= (others =>'0');
        valid_in <= '0';
        Ain  <= (others=>(others => '0'));
        Win  <= (others=>(others => '0')); 
      elsif (clk = '1' and clk'event) then
    	 if (not endfile(AMatrixRead) and load_new_data = '1') then    -- Read lines (row) from files
		    readline(AMatrixRead, Arow);
		    readline(WMatrixRead, Wrow);
		    if (count = MATRIX_SIZE-1) then
		      count <= (others => '0');
		    else  
		      count <= count + '1';
		    end if;  
            
		    for j in 0 to (MATRIX_SIZE-1) loop    -- Read elements (column) from files
			  read(Arow, Aelement);
			  read(Wrow, Welement);
			  Ain(j) <= std_logic_vector(to_signed(Aelement, data_width));
			  Win(j) <= std_logic_vector(to_signed(Welement, data_width));
		   end loop;
		   valid_in <= load_new_data;
		 else
		   valid_in <= '0';  
		 end if;  
         
	    
	
	end if;


   end process;
   
   process(clk, reset)
	file outputMatrixWrite  	: text open write_mode is "C:\erbwkf\final project\Approximate\outConfigMulti.txt";
    	variable  outputRow         	: line;
    	variable  outputelement		: integer;
 
   begin
      if (reset = '1') then

        count_read <= (others => '0'); 
        read_result <= '0';
      elsif (clk = '1' and clk'event) then
          
         if (result_rdy = '1' and read_result = '0') then
            read_result <= '1';
         elsif ( read_result = '1') then
                    
            if (count_read = MATRIX_SIZE-1) then
               count_read <= (others => '0');
               read_result <= '0';
            else
               count_read <= count_read+ '1';
            end if;  
         end if;
         if (valid_out = '1') then
            for j in 0 to (MATRIX_SIZE-1) loop    -- Read elements (column) from files
              outputelement := conv_integer(Yout(j));
			  write(outputRow, outputelement);
			  write(outputRow, ' ');
		   end loop;
           writeline(outputMatrixWrite,outputRow );     
           
         end if;  
 
	end if;
        
   end process;
   
   dut :matrix_top Port map
       ( CLK             => clk,
	 reset           => reset,
         valid_in        => valid_in,
         load_new_data   => load_new_data,
         Ain             => Ain,
         Win             => Win,
         result_rdy      => result_rdy,
	 read_result     => read_result,
	 valid_out       => valid_out,
	 Yout            => Yout  
  
  );
 end behave;
