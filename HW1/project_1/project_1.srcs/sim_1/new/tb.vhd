----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2024/09/21 
-- Design Name: 
-- Module Name: tb_two_counter
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Testbench for two_counter
-- 
-- Dependencies: two_counter.vhdl
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_two_counter is
end tb_two_counter;

architecture Behavioral of tb_two_counter is

    -- Component Declaration for the Unit Under Test (UUT)
    component two_counter
        Port ( i_clk : in STD_LOGIC;
               i_rst : in STD_LOGIC;
               o_count1 : out STD_LOGIC_VECTOR (3 downto 0);
               o_count2 : out STD_LOGIC_VECTOR (3 downto 0)
             );
    end component;

    -- Signal Declarations
    signal clk : STD_LOGIC := '0';
    signal rst : STD_LOGIC := '0';
    signal count1 : STD_LOGIC_VECTOR (3 downto 0);
    signal count2 : STD_LOGIC_VECTOR (3 downto 0);

    -- Clock period definition
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: two_counter
        Port map (
            i_clk => clk,
            i_rst => rst,
            o_count1 => count1,
            o_count2 => count2
        );

    -- Clock generation process
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Stimulus process
    stimulus_process : process
    begin
        -- Initialize the reset
        rst <= '0';
        wait for 20 ns;  -- Hold reset for some time
        rst <= '1';

        -- Wait for a while to observe counter behavior
        wait for 200 ns;

        -- Add more stimulus if needed
        -- e.g., toggling reset or observing outputs
        
        wait; -- Wait forever to finish simulation
    end process;

end Behavioral;
