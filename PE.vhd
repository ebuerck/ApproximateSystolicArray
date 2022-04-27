library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_arith.all;

entity PE is
generic (
    DW  : integer := 4;
	N   : integer := 4
);
	port(Ain,Win   : in std_logic_vector(DW-1 downto 0);		--A and W matrix elements
	     Addin     : in std_logic_vector(DW*2+N- 1 downto 0);	--output from above PE to be added to Ain x Win
	     CLK       : in std_logic;
	     RESET     : in std_logic;
	     Valid_in  : in std_logic;					--tells when inputs are valid
	     Aout      : out std_logic_vector(DW- 1 downto 0);		--Aout=Ain to be passed to PE on the right
	     Addout    : out std_logic_vector(DW*2+N- 1 downto 0);	--output for Ain x Win + Addin
	     Valid_out : out std_logic					--tells when outputs are valid
		 );
end PE;

 
Architecture Behaviorial of PE is

--Inserted the Comp. of the Accurate Multibit Adder
component Approx8x8MultLit is
	port (A   	 : in std_logic_vector(7 downto 0);
		  B 	 : in std_logic_vector(7 downto 0);
		  Output    : out std_logic_vector(15 downto 0) );
end component;
 
 --signals already present
 signal Win_reg : std_logic_vector(DW- 1 downto 0);
 signal Win_int : std_logic_vector(DW- 1 downto 0); 
 signal valid_in_d : std_logic;
 
 --TESTing of doing some port mapping
 signal Sum_buff : std_logic_vector(15 downto 0);
 signal Atest : std_logic_vector(7 downto 0);
 signal Btest : std_logic_vector(7 downto 0);
 

 
begin 
   Win_int <= Win when (valid_in_d = '0' and valid_in ='1') else
              Win_reg when (valid_in ='1') else
              (others => '0');
           
    Atest <= Ain;
    Btest <= Win_int;  
    Test: Approx8x8MultLit port map(Atest,Btest,Sum_buff);
    process(CLK , RESET)
    begin
	    if (RESET = '1') then
		  Addout <= (others => '0');
		  Aout     <= (others => '0');
		  Win_reg   <= (others => '0');
		  valid_in_d <= '0';
		elsif CLK'event and (CLK = '1') then
		  if (Valid_in = '1' and valid_in_d = '0') then
		     Win_reg <= Win;
		  end if;   
		  if (Valid_in = '1') then
		    --Addout <=  Addin + Ain*Win_int;
		    Addout <= Addin + Sum_buff;
		    Aout   <= Ain;	
	      end if;
          valid_in_d <= Valid_in;		  
		end if;		
	end process;
	valid_out <= valid_in_d;
end Behaviorial;

