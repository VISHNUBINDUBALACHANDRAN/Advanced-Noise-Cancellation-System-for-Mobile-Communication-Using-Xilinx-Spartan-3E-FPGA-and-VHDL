library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_unsigned.all;
    use ieee.numeric_std.all;
      
entity FIR_filter_low is
  generic ( n : integer := 16; tab:integer:=50);
    port(clk:in  std_logic;
           x:in  std_logic_vector(n-1 downto 0);
           y:out std_logic_vector((2*n)-1 downto 0)
         );
end FIR_filter_low;

Architecture operation of FIR_filter_low is
  
  component Z_Delay is
  generic ( n : integer);
    port(clk:in  std_logic;
           D:in  std_logic_vector(n-1 downto 0):=(others=>'0');
           Q:out std_logic_vector(n-1 downto 0):=(others=>'0')
         );
  end component;
  
  component FIR_Multiplier_Array is
  Generic (n:integer:=16);
  port(   multiplicand: in std_logic_vector(n-1 downto 0);
            multiplier: in std_logic_vector(n-1 downto 0);
                   MUL: out std_logic_vector((2*n)-1 downto 0));
   end component;
   
   component RCA is
    generic ( n : integer := 8);
     port(a,b:in std_logic_vector(n-1 downto 0);
          cin:in std_logic;
          s:out std_logic_vector(n-1 downto 0);
          cout:out std_logic
          );
   end component ;

 Type TABS is array (0 to tab-1) of std_logic_vector(n-1 downto 0);
 
 Type  Co_effecient_momory is array (0 to tab-1) of std_logic_vector(n-1 downto 0);
 Type  Product_momory is array (0 to tab-1) of std_logic_vector((2*n)-1 downto 0);
     Type int_Co_effecient_momory is array (0 to tab-1) of integer;
    Constant int_Co_effecient : int_Co_effecient_momory := (
       -47,43,76,-33,-134,0,222,88,-321,-264,391,547,-372,-940,186,1423,
       267,-1950,-1127,2462,2691,-2891,-5995,3176,20527,29488,20527,3176,
       -5995,-2891,2691,2462,-1127,-1950,267,1423,186,-940,-372,547,391,
       -264,-321,88,222,0,-134,-33,76,43
);
    
    Signal Co_effecient : Co_effecient_momory;
  
    signal TAB_Delay:TABS:=(others=>(others=>'0'));
    signal Products:Product_momory;
    signal Adder_tree:Product_momory;
    signal C: std_logic_vector(tab-1 downto 0):=(others=>'0');
 begin
   
    
     
                        TAB_Delay(0)<=x;
   
   FIR_Delay:         for i in 1 to tab-1 generate
                
      Tab_Delays:    Z_Delay generic map (n)
                                port map (clk,TAB_Delay(i-1),TAB_Delay(i));
              
                      end generate;
   
  
FIR_Co_eff_multi:   for i in 0 to tab-1 generate 
   
    Co_effecient(i)<=std_logic_vector(to_signed(int_Co_effecient((tab-1)-i),n));
           
           Multi:   FIR_Multiplier_Array  generic map (n)
                            port map(TAB_Delay(i),Co_effecient(i),Products(i));
                                      
                     end generate;

  

                  adder_TREE(0)<=Products(0);
                         

FIR_ADDER_TREE:   for i in 1 to tab-1 generate
 
            ADDER     : RCA generic map(2*n)
                            port map(Products(i),Adder_TREE(i-1),'0',Adder_TREE(i),C(i)) ;  
          
                  end generate;

                        y<=Adder_TREE(n-1);

 end;

