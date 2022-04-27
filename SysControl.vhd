library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
library work;
use work.matrix256.all;

entity FSM is
	port(CLK            	    : in std_logic;
	     reset           	    : in std_logic;
             valid_in       	    : in std_logic;
             load_new_data   	    : out std_logic;	     
	     valid_in_shifted	    : out bit_array;
	     clear_PE        	    : out std_logic;
	     result_rdy     	    : out std_logic;
	     read_result    	    : in std_logic;
	     valid_out       	    : out std_logic;
	     write_en       	    : out std_logic;
	     write_address   	    : out std_logic_vector(ADDR_SIZE-1 downto 0);
	     read_out_mem           : out std_logic;
	     read_address_out_mem   : out std_logic_vector(ADDR_SIZE-1 downto 0)
    );
end FSM;

architecture behave of FSM is 

type state is (NEW_DATA , CALC, DONE);
signal current_matrix_st : state;
signal next_matrix_st    : state;

signal  valid_in_array   : bit_array;
signal  Ain_sig          : data_array; 
signal read_en           : std_logic;         
signal zero_array        : bit_array;
signal wr_count          : std_logic_vector(ADDR_SIZE-1  downto 0);
signal read_in_data      : std_logic;
signal rd_in_data_count  : std_logic_vector(ADDR_SIZE  downto 0);
begin
    zero_array <= (others => '0');
    write_address <= wr_count;
    
  
	process(CLK, RESET)
	begin
	    if (reset = '1') then
	       current_matrix_st <= NEW_DATA;
	    elsif (CLK'event and CLK = '1') then
		    current_matrix_st <= next_matrix_st;
	    end if;
    end process;
    
    process(current_matrix_st,wr_count,valid_in,rd_in_data_count,valid_in_array,zero_array,read_result)
    begin		    
			case current_matrix_st is 
				when NEW_DATA =>
				  clear_PE      <= '1';
				  load_new_data <= '1';
				  read_out_mem     <= '0';
				  
				  read_in_data   <= '0';
				  if (wr_count = MATRIX_SIZE -1) then
				     next_matrix_st <= CALC;
				  else
				     next_matrix_st <= NEW_DATA;  
				  end if;   
				  write_en  <= valid_in;
   
				  result_rdy <= '0'; 
				
				when CALC =>
				   clear_PE <= '0';
				   load_new_data <= '0';
				   read_out_mem <= '0';
				   write_en  <= '0';
				   if (rd_in_data_count =  MATRIX_SIZE) then
				      read_in_data   <= '0';
				   else   
				      read_in_data   <= '1';
				   end if;   
               
				   
				   if ( valid_in_array = zero_array and (rd_in_data_count =  MATRIX_SIZE) ) then
				      next_matrix_st <= DONE;
				   else
				      next_matrix_st <=  CALC;
				   end if;   
				   result_rdy <= '0';  
				   
				   
				   
				
				when others =>  -- DONE
				  clear_PE <= '0';
				  result_rdy <= '1';
				  load_new_data <= '0';
				  if (wr_count =  MATRIX_SIZE -1) then
				     next_matrix_st <=  NEW_DATA;
				  else
				      next_matrix_st <= DONE;
				  end if;      
				  
				  read_out_mem <= read_result;
				  read_in_data   <= '0';		  
				  
				
					

			end case;

	end process;


    process(clk, reset) 
    begin
        if (reset = '1') then
	       valid_in_array <= (others => '0');
	       wr_count <= (others => '0');
	       rd_in_data_count <= (others => '0');
	       valid_out <= '0';
	elsif (CLK'event and CLK = '1') then
		   if ( current_matrix_st =  DONE) then
		     valid_out <= read_result;
		   else
		     valid_out <= '0';
		   end if;    
		   if (current_matrix_st = NEW_DATA) then
		      valid_in_array <= (others => '0');
		      
		   else   
		      valid_in_array <= (read_in_data & valid_in_array(0 to MATRIX_SIZE-2));
		      
		   end if; 
		   
		   if (valid_in = '1' or read_result = '1') and 
		       (current_matrix_st = NEW_DATA or current_matrix_st =  DONE) then 
		      if (wr_count =  MATRIX_SIZE -1) then
		         wr_count <= (others => '0');
		      else
		         wr_count <= wr_count + '1';
		      end if;  
		   end if; 
		   if (current_matrix_st = NEW_DATA)then
		      rd_in_data_count <= (others => '0');
		   elsif  (read_in_data = '1') then
		     if (rd_in_data_count =  MATRIX_SIZE) then
		        rd_in_data_count <=  rd_in_data_count;
		     else 
		        rd_in_data_count <= rd_in_data_count +'1';
		     end if;
		   end if;  
		               
		
		end if;
    end process;
    
    valid_in_shifted <= valid_in_array;
    
read_address_out_mem <= wr_count;

					
end behave;