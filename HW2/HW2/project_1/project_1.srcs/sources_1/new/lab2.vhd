----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2024/09/25 17:37:08
-- Design Name: 
-- Module Name: pwm - Behavioral
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

entity two_counters is
    Port ( i_clk : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           i_upbnd1 : in STD_LOGIC_VECTOR (3 downto 0);
           i_upbnd2 : in STD_LOGIC_VECTOR (3 downto 0);           
           o_count1 : out STD_LOGIC_VECTOR (3 downto 0);
           o_count2 : out STD_LOGIC_VECTOR (3 downto 0);
           o_state  : out STD_LOGIC
           );
end two_counters;

architecture Behavioral of two_counters is
type STATE_TYPE is (counter1_is_counting, counter2_is_counting);
signal state:STATE_TYPE;
signal count1:STD_LOGIC_VECTOR (3 downto 0);
signal count2:STD_LOGIC_VECTOR (3 downto 0);
signal upbnd1:STD_LOGIC_VECTOR (3 downto 0);
signal upbnd2:STD_LOGIC_VECTOR (3 downto 0);
begin
o_count1 <= count1;
o_count2 <= count2;
upbnd1 <= i_upbnd1;
upbnd2 <= i_upbnd2;

process(state)
begin
if state = counter1_is_counting then
    o_state <= '1';
else
    o_state <= '0';
end if;
end process; 

FSM1:process(i_clk, i_rst)
begin
    if i_rst='0' then
        state <= counter1_is_counting; 
    elsif i_clk'event and i_clk='1' then
        case state is
            when counter1_is_counting =>
                 if count1 = upbnd1 then
                      state <= counter2_is_counting;
                 end if;
            when counter2_is_counting =>
                 if count2 = upbnd2 then
                      state <= counter1_is_counting;
                 end if;            
            when others =>
                null;
        end case;
    end if;
end process;

counter1_p:process(i_clk, i_rst)
begin
    if i_rst='0' then
        count1 <= "0000"; 
    elsif i_clk'event and i_clk='1' then
        case state is
            when counter1_is_counting =>
                count1 <= count1 + '1';
                --count2  <= "0000";
            when counter2_is_counting =>
                --count2 <= count2 + '1';
                count1 <= "0000";
            when others =>
                null;
        end case;
    end if;
end process;

counter2_p:process(i_clk, i_rst)
begin
    if i_rst='0' then
        count2 <= "0000"; 
    elsif i_clk'event and i_clk='1' then
        case state is
            when counter1_is_counting =>
                --count1 <= count1 + '1';
                count2  <= "0000";
            when counter2_is_counting =>
                count2 <= count2 + '1';
                --count1 <= "0000";
            when others =>
                null;
        end case;
    end if;
end process;

end Behavioral;
