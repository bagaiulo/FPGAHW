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

entity pwm is
    Port ( i_clk       : in  STD_LOGIC;
           i_rst       : in  STD_LOGIC;
           i_speed_now : in  STD_LOGIC_VECTOR (3 downto 0);
           i_th_speed  : in  STD_LOGIC_VECTOR (3 downto 0);
           i_target    : in  STD_LOGIC_VECTOR (3 downto 0);                        
--           o_upbnd1    : out STD_LOGIC_VECTOR (7 downto 0);
--           o_upbnd2    : out STD_LOGIC_VECTOR (7 downto 0);
           o_pwm       : out STD_LOGIC 
    );
end pwm;

architecture Behavioral of pwm is
component two_counters
    Port ( i_clk : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           i_upbnd1 : in STD_LOGIC_VECTOR (3 downto 0);
           i_upbnd2 : in STD_LOGIC_VECTOR (3 downto 0);           
           o_count1 : out STD_LOGIC_VECTOR (3 downto 0);
           o_count2 : out STD_LOGIC_VECTOR (3 downto 0);
           o_state  : out STD_LOGIC
           );
end component;

type STATE_TYPE is (full_speed, speeding_up, speeding_dn, final); -- 100%, 75%, 25%, 50%
signal state     : STATE_TYPE;
signal pwm_state : STD_LOGIC;
signal upbnd1    : STD_LOGIC_VECTOR (3 downto 0);
signal upbnd2    : STD_LOGIC_VECTOR (3 downto 0);
signal count1    : STD_LOGIC_VECTOR (3 downto 0); -- not used
signal count2    : STD_LOGIC_VECTOR (3 downto 0); -- not used
begin

o_pwm <= pwm_state;
pwm_counters: two_counters
port map (
    i_clk => i_clk,
    i_rst => i_rst,
    i_upbnd1 => upbnd1,
    i_upbnd2 => upbnd2,            
    o_count1 => count1,
    o_count2 => count2,
    o_state  => pwm_state
);


FSM2:process(i_clk, i_rst)
begin
    if i_rst='0' then
        state <= full_speed; 
    elsif i_clk'event and i_clk='1' then
        case state is
            when full_speed =>
                if i_speed_now < i_th_speed then
                    state <= full_speed;
                elsif i_speed_now >= i_th_speed and i_speed_now < i_target then
                    state <= speeding_up;                
                elsif i_speed_now > i_target then
                    state <= speeding_dn;                
                elsif i_speed_now = i_target then
                    state <= final;                               
                end if;
            when speeding_up =>
                if i_speed_now < i_th_speed then
                    state <= full_speed;
                elsif i_speed_now >= i_th_speed and i_speed_now < i_target then
                    state <= speeding_up;                
                elsif i_speed_now > i_target then
                    state <= speeding_dn;                
                elsif i_speed_now = i_target then
                    state <= final;                               
                end if;            
            when speeding_dn =>
                if i_speed_now < i_th_speed then
                    state <= full_speed;
                elsif i_speed_now >= i_th_speed and i_speed_now < i_target then
                    state <= speeding_up;                
                elsif i_speed_now > i_target then
                    state <= speeding_dn;                
                elsif i_speed_now = i_target then
                    state <= final;                               
                end if;            
            when final       =>    
                if i_speed_now < i_th_speed then
                    state <= full_speed;
                elsif i_speed_now >= i_th_speed and i_speed_now < i_target then
                    state <= speeding_up;                
                elsif i_speed_now > i_target then
                    state <= speeding_dn;                
                elsif i_speed_now = i_target then
                    state <= final;                               
                end if;                                
            when others =>
                null;
        end case;
    end if;
end process;

upper_bounds:process(i_clk, i_rst, state)
begin
    if i_rst='0' then
        upbnd1 <= "1111";
        upbnd2 <= "0000";          
    elsif i_clk'event and i_clk='1' then
        case state is
            when full_speed =>
                upbnd1 <= "1111";
                upbnd2 <= "0000";  
            when speeding_up =>
                upbnd1 <= "1100"; 
                upbnd2 <= "0100";              
            when speeding_dn =>
                upbnd1 <= "0100"; 
                upbnd2 <= "1100";                             
            when final       =>    
                upbnd1 <= "1000"; 
                upbnd2 <= "1000";    
            when others =>
                null;
        end case;
    end if;
end process;



end Behavioral;