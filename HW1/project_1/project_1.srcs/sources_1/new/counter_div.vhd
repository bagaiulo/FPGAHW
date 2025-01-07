----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2024/09/21 15:17:45
-- Design Name: 
-- Module Name: counter - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity two_counter is
    Port ( i_clk : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           o_count1 : out STD_LOGIC_VECTOR (3 downto 0);
           o_count2 : out STD_LOGIC_VECTOR (3 downto 0)
         );
end two_counter;

architecture Behavioral of two_counter is

signal count1:STD_LOGIC_VECTOR (3 downto 0);
signal count2:STD_LOGIC_VECTOR (3 downto 0);
signal state:STD_LOGIC;

signal count1_up:STD_LOGIC_VECTOR (3 downto 0);
signal count2_up:STD_LOGIC_VECTOR (3 downto 0);
signal count1_down:STD_LOGIC_VECTOR (3 downto 0);
signal count2_down:STD_LOGIC_VECTOR (3 downto 0);
signal clk_cnt:STD_LOGIC_VECTOR (24 downto 0);
signal clk_clk:STD_LOGIC;
begin

count1_up <= "1110";  -- è³¦å?¼ç‚º4ä½å?ƒä?Œé?²ä?å??
count2_up <= "1001";  -- è³¦å?¼ç‚º4ä½å?ƒä?Œé?²ä?å??
count1_down <= "0001";  -- è³¦å?¼ç‚º4ä½å?ƒä?Œé?²ä?å??
count2_down <= "0010";  -- è³¦å?¼ç‚º4ä½å?ƒä?Œé?²ä?å??

o_count1 <= count1;
o_count2 <= count2;

clk_clk<=clk_cnt(24);
  div_clk:process(i_clk, i_rst)begin
        if i_rst = '0' then
            clk_cnt <= (others => '0');
        elsif i_clk = '1' and i_clk'event then
            clk_cnt <= clk_cnt + '1';
        end if;
     end process;

FSM: process(i_clk,i_rst)
begin
    if i_rst= '0' then
       state <= '0';
    elsif i_clk'event and i_clk = '1' then
       case state is
           when '0' =>
               if count1= count1_up then
                   state <= '1';
               end if;
           when '1' =>
               if count2=count2_down then 
                   state <= '0';
               end if;
           when others =>
               null;
       end case;
    end if;
end process;

counter1p: process(clk_clk,i_rst,state,count1_down)
begin
    if i_rst = '0' then
       count1 <=count1_down;
    elsif clk_clk'event and clk_clk='1' then
       case state is
           when '0' =>
              count1 <= count1 + '1';
           when '1' =>
               count1 <=count1_down;
           when others =>
               null;
       end case;
    end if;
end process;

counter2p:process(clk_clk,i_rst,state,count2_up)
begin
    if i_rst = '0' then
       count2 <=count2_up;
    elsif clk_clk'event and clk_clk='1' then
       case state is
           when '0' =>
               count2 <=count2_up;
           when '1' =>
           count2<=count2 - '1';
           when others =>
               null;
       end case;
    end if;
end process;

end Behavioral;
