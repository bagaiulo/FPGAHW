----------------------------------------------------------------------------------
-- ���q: 
-- �u�{�v: 
-- 
-- �Ыؤ��: 2024/05/24
-- �]�p�W��: 
-- �Ҷ��W��: ball_game_tb - Behavioral
-- �M�צW��: 
-- �ؼг]��: 
-- �u�㪩��: 
-- �y�z: Testbench for ball_game
-- 
-- �̿ඵ: 
-- 
-- �׭q:
-- �׭q 0.01 - ���Ы�
-- ���[����:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ball_game_tb is
end ball_game_tb;

architecture Behavioral of ball_game_tb is

    -- Component Declaration for the Unit Under Test (UUT)
    component ball_game
    port(
        clk : in  std_logic;
        rst : in  std_logic;
        SW1 : in  std_logic;
        SW2 : in  std_logic;
        LED : out std_logic_vector(7 downto 0);
        seg1 : out std_logic_vector(6 downto 0);
        seg2 : out std_logic_vector(6 downto 0)
    );
    end component;

    -- Testbench signals
    signal clk_tb : std_logic := '0';
    signal rst_tb : std_logic := '0';
    signal SW1_tb : std_logic := '0';
    signal SW2_tb : std_logic := '0';
    signal LED_tb : std_logic_vector(7 downto 0);
    signal seg1_tb : std_logic_vector(6 downto 0);
    signal seg2_tb : std_logic_vector(6 downto 0);

    -- Clock period definitions
    constant clk_period : time := 20 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: ball_game port map (
        clk => clk_tb,
        rst => rst_tb,
        SW1 => SW1_tb,
        SW2 => SW2_tb,
        LED => LED_tb,
        seg1 => seg1_tb,
        seg2 => seg2_tb
    );

    -- Clock process definitions
    clk_process : process
    begin
        clk_tb <= '0';
        wait for clk_period/2;
        clk_tb <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Reset the system
        rst_tb <= '1';
        wait for 100 ns;  -- �W�[���ݮɶ�
        rst_tb <= '0';
               wait for 20 ns; -- �W�[���ݮ�
        SW1_tb <= '1';
        wait for 40 ns;
         SW1_tb <= '0';
           wait for 180 ns;
           SW2_tb <= '1';
        wait for 40 ns;
         SW2_tb <= '0';
  
        wait for 160 ns;  -- �W�[���ݮɶ�
      SW2_tb <= '0';
  
       
       

        -- Hit by right player
      
        wait for 200 ns;  -- �W�[���ݮɶ�

        -- Hit by left player
        SW1_tb <= '1';
        wait for 20 ns;
        SW1_tb <= '0';
       
    end process;

end Behavioral;