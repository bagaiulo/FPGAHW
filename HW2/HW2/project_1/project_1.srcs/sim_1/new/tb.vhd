----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2024/09/18 23:17:20
-- Design Name: 
-- Module Name: count_tb - Behavioral
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
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY pwm_tb is
end pwm_tb;

architecture Behavioral of pwm_tb is

    COMPONENT pwm
    port(
           i_clk       : in  STD_LOGIC;
           i_rst       : in  STD_LOGIC;
           i_speed_now : in  STD_LOGIC_VECTOR (3 downto 0);
           i_th_speed  : in  STD_LOGIC_VECTOR (3 downto 0);
           i_target    : in  STD_LOGIC_VECTOR (3 downto 0);                        
--           o_upbnd1    : out STD_LOGIC_VECTOR (7 downto 0);
--           o_upbnd2    : out STD_LOGIC_VECTOR (7 downto 0);
           o_pwm       : out STD_LOGIC
           );
    end COMPONENT;
    
    signal i_clk : std_logic := '0';
    signal i_rst : std_logic := '0';
    
    signal i_speed_now : STD_LOGIC_VECTOR (3 downto 0);
    signal i_th_speed : STD_LOGIC_VECTOR (3 downto 0);
    signal i_target : STD_LOGIC_VECTOR (3 downto 0);
    
    signal o_pwm : std_logic;
    
    constant i_clk_period : time := 10 ns;
    
begin
    
    uut : pwm port map(
    i_clk => i_clk,
    i_rst => i_rst,
    i_speed_now => i_speed_now,
    i_th_speed =>  i_th_speed,
    i_target =>  i_target,
    o_pwm => o_pwm
    );
    
    s_clk_process : process
  begin
      i_clk <= '0';
      wait for i_clk_period/2;
      i_clk <= '1';
      wait for i_clk_period/2;
  end process;
 
   stin_process : process
  begin
      i_rst <= '0';
      i_target <= "1110";
      i_th_speed <="1100";
      wait for 100 ns;
      i_rst <= '1';
      wait for i_clk_period * 20;
      
      wait;
  end process;
  full : process
   begin
       i_speed_now <= "0011";
       wait for 265 ns;
       i_speed_now <= "1101";
       wait for 180 ns;
       i_speed_now <= "1111";      
       wait for 180 ns;
       i_speed_now <= "1110";    
       
       wait;
   end process;
       
end Behavioral;