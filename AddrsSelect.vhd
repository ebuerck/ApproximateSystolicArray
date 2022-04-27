
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library work;
use work.matrix256.all;

entity AddrsSelect is
  Port ( clk 			: in std_logic;
         reset 			: in std_logic;
         write_en 		: in std_logic;
         write_address   	: in std_logic_vector(ADDR_SIZE-1 downto 0);
         read_out_mem        	: in std_logic;
	 read_address_out_mem   : in std_logic_vector(ADDR_SIZE-1 downto 0);
         Ain      		: in data_array;
         Win      		: in data_array;
         read_en  		: in bit_array;
         Ain_shifted  		: out data_array;
         Win_shifted  		: out data_array;
         valid_in_addout	: in bit_array;
         Addout_in      	: in data_array_add;
         Yout            	: out data_array_add
          
         
   );
end AddrsSelect;

architecture Behavioral of AddrsSelect is
  
  signal Ain_mem  : mem_array;
  signal Win_mem  : mem_array;
  signal Yout_mem : mem_out_array;

  signal read_Address 		    : std_logic_vector(ADDR_SIZE downto 0);
  signal Ain_address  		    : address_array;
  signal Addin_address  	    : address_array;
  signal read_out_mem_reg           :  std_logic;
  signal read_out_mem_address_reg   :  std_logic_vector(ADDR_SIZE-1 downto 0);
        
begin

  
  process(clk) 
  begin

     if (clk = '1' and clk'event) then
        if (write_en = '1') then
           for i in 0 to MATRIX_SIZE -1 loop 
             Ain_mem(i)(conv_integer(write_Address(ADDR_SIZE-1  downto 0))) <= Ain(i);
             Win_mem(i)(conv_integer(write_Address(ADDR_SIZE-1  downto 0))) <= Win(i);
           end loop; 
        end if;
     end if;      
  end process;
  
  process(clk, reset)
  begin
     if (Reset = '1') then
        Ain_address <= (others => (others => '0'));
     elsif (clk = '1' and clk'event) then
        for i in 0 to MATRIX_SIZE -1 loop
           if (read_en(i) = '1') then
              Ain_address(i) <= Ain_address(i) + '1';
           end if;
        end loop;       
     end if;               
  end process;
  
  process(Ain_address,Ain_mem ,Win_mem,read_out_mem_address_reg,read_out_mem_reg) begin 
    for i in 0 to MATRIX_SIZE -1 loop
       Ain_shifted(i) <= Ain_mem(i)(conv_integer(Ain_address(i)));       
       Win_shifted(i) <= Win_mem(i)(conv_integer(Ain_address(i)));
       if (read_out_mem_reg = '1') then
         yout(i)        <= Yout_mem(i)(conv_integer(read_out_mem_address_reg));
       else
         yout(i) <= (others => '0');
       end if;     
     end loop;
  end process;       
 
 
   process(clk, reset)
  begin
     if (Reset = '1') then
        Addin_address <= (others => (others => '0'));
        read_out_mem_reg <= '0';
        read_out_mem_address_reg <= (others => '0');        
     elsif (clk = '1' and clk'event) then
        read_out_mem_reg <= read_out_mem;
        read_out_mem_address_reg <=read_address_out_mem;
        for i in 0 to MATRIX_SIZE -1 loop
           if (valid_in_addout(i) = '1') then
              Addin_address(i) <= Addin_address(i) + '1';
              Yout_mem(i)(conv_integer(Addin_address(i))) <= Addout_in(i);
           end if;
        end loop;       
     end if;               
  end process; 
  
end Behavioral;
