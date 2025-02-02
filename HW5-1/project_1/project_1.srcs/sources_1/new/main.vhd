library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.NUMERIC_STD.ALL;

entity main is
    Port(
        clock       : in STD_LOGIC;
        reset       : in STD_LOGIC;
        SQUARE1_up  : in STD_LOGIC;
        SQUARE1_down: in STD_LOGIC;
        SQUARE2_up  : in STD_LOGIC;
        SQUARE2_down: in STD_LOGIC;
        clocr_btn   : in STD_LOGIC_VECTOR (2 downto 0); -- 顏色選擇按鈕
        ledout      : out STD_LOGIC_VECTOR (2 downto 0);
        o_red       : out STD_LOGIC_VECTOR (3 downto 0);
        o_green     : out STD_LOGIC_VECTOR (3 downto 0);
        o_blue      : out STD_LOGIC_VECTOR (3 downto 0);
        o_hs        : out STD_LOGIC;
        o_vs        : out STD_LOGIC
    );
end main;

architecture Behavioral of main is
    signal clk_div_cnt : std_logic_vector(26 downto 0) := (others => '0'); -- 除頻counter
    signal to_vga_clk : std_logic := '0'; -- 給VGA的時脈
    signal cclk       : std_logic := '0'; 
    
    -- 以下VGA參數
    constant C_H_SYNC_PULSE : integer := 96;
    constant C_H_BACK_PORCH : integer := 48;
    constant C_H_ACTIVE_TIME : integer := 640;
    constant C_H_LINE_PERIOD : integer := 800;
    
    constant C_V_SYNC_PULSE : integer := 2;
    constant C_V_BACK_PORCH : integer := 33;
    constant C_V_ACTIVE_TIME : integer := 480;
    constant C_V_FRAME_PERIOD : integer := 525;
    
    signal R_h_cnt : STD_LOGIC_VECTOR (11 downto 0) := (others => '0');
    signal R_v_cnt : STD_LOGIC_VECTOR (11 downto 0) := (others => '0');
    signal W_active_flag : STD_LOGIC;
    
    signal x  : integer := 320;
    signal y  : integer := 240;
    signal r  : integer := 10;
    
    signal pixel_x : INTEGER := 0;
    signal pixel_y : INTEGER := 0;
    
    signal move_up   : std_logic := '0';  
    signal move_left : std_logic := '0';  
    
    signal SQUARE_LEFT   : integer := 50;
    signal SQUARE_RIGHT  : integer := 60;
    signal SQUARE_TOP    : integer := 190;
    signal SQUARE_BOTTOM : integer := 290;
    
    signal SQUARE_LEFT2   : integer := 590;
    signal SQUARE_RIGHT2  : integer := 600;
    signal SQUARE_TOP2    : integer := 190;
    signal SQUARE_BOTTOM2 : integer := 290;
    
    signal stop : STD_LOGIC := '0';
    
    type State is (start, Lsit, Rsit, Lserve, Rserve, win);
    signal cs : State;
    
    signal Lcount : STD_LOGIC_VECTOR (2 downto 0) := (others => '0');
    signal Rcount : STD_LOGIC_VECTOR (2 downto 0) := (others => '0');
    
    signal o_Lcount : STD_LOGIC_VECTOR (2 downto 0) := (others => '0');
    signal o_Rcount : STD_LOGIC_VECTOR (2 downto 0) := (others => '0');
    
    signal clka :STD_LOGIC;-----IP設定
    signal wea : STD_LOGIC;
    signal addra : STD_LOGIC_VECTOR (13 downto 0);
    signal dina : STD_LOGIC_VECTOR (7 downto 0);
    signal douta :STD_LOGIC_VECTOR (7 downto 0);
    
    
    signal wclk  :  std_logic;-------RTl設定
    signal RTL_wen   :  std_logic;
    signal waddr :  STD_LOGIC_VECTOR (13 downto 0);
    signal wdata :  STD_LOGIC_VECTOR (7 downto 0);
    signal rclk  :  std_logic;
    signal raddr :STD_LOGIC_VECTOR (13 downto 0);
    signal rtl_rdata : STD_LOGIC_VECTOR (7 downto 0);
    
    signal bram_addr : STD_LOGIC_VECTOR(13 downto 0);
    signal bram_data : STD_LOGIC_VECTOR(7 downto 0);

    component blk_mem_gen_0
        port (
            clka : IN STD_LOGIC;
            addra : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
            douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
            );
    end component;
  
   
                
    component BRAM
        port (
            wclk  : in std_logic;
            wen   : in std_logic;
            waddr : in integer range 0 to 9999;
            wdata : in std_logic_vector(7 downto 0);
            rclk  : in std_logic;
            raddr : in integer range 0 to 9999;
            rdata :out std_logic_vector(7 downto 0)
            );
    end component;
  
    begin
     uut_image: blk_mem_gen_0
            port map (
                clka  => clock,
                addra => bram_addr, 
                douta => bram_data
                );
                
        uut_bram: BRAM
            port map (
                wclk =>clock,
                wen  =>RTL_wen,
                waddr =>to_integer(unsigned(bram_addr)),
                wdata =>bram_data,
                rclk  =>clock,
                raddr=>to_integer(unsigned(bram_addr)),
                rdata =>rtl_rdata
               );
                
     
--     這裡可以加入你的其他邏輯或進程
    
    -- ??除?器
    div_clk: process(clock, reset)
    begin
        if reset = '1' then
            clk_div_cnt <= (others => '0');
        elsif rising_edge(clock) then
            clk_div_cnt <= clk_div_cnt + 1;
        end if;
    end process div_clk;
    
    to_vga_clk <= clk_div_cnt(1);
    cclk<=clk_div_cnt(19);
   ---------園移動
     cir_process: process(cclk, reset,stop,SQUARE1_up,SQUARE1_down,SQUARE2_up,SQUARE2_down)
    begin
        if reset = '1' then
          x<=320;
          y<=240;
          cs<=start;
        elsif rising_edge(cclk) then
        ------------------------------------------------------------------------------------------------------------------------
            case cs is 
            ------------------------------------------------------------------------------------------------
                when start=>
                    x<=320;
                    y<=240;
                    if SQUARE1_up='1' or SQUARE1_down='1'then
                        cs<=Lserve;
                    elsif SQUARE2_up='1' or SQUARE2_down='1' then
                     cs<=Rserve;
                     end if;
            ----------------------------------------------------------------------------------------------------
                 when Lserve =>
                -- 碰到左邊板子反彈
                    if (SQUARE_RIGHT = x - 50) and (y+49 >= SQUARE_TOP and y-49 <= SQUARE_BOTTOM) then
                        move_left <= '0';
                -- 碰到右邊板子反彈
                    elsif (SQUARE_LEFT2 = x + 49) and (y+49 >= SQUARE_TOP2 and y-49 <= SQUARE_BOTTOM2) then
                        move_left <= '1';
                    end if;
                -- 碰到上下邊界反彈
                    if y + 50>= C_V_ACTIVE_TIME then
                         move_up <= '0';
                    elsif y - 70 <= 0 then
                         move_up <= '1';
                    end if;     
                -- 移動球
                    if move_up = '1' then
                        y <= y + 1;
                    else
                        y <= y - 1;
                    end if;
                    if move_left = '1' then
                        x <= x - 1;
                    else
                        x <= x + 1;
                    end if;
                     if x-100<=0 then
                        cs<=Rsit;
                        Rcount<=Rcount+1;
                     elsif x>=750 then
                        cs<=Lsit;
                        Lcount<=Lcount+1;
                    end if;
                    ----------------------------------------------------------------------------------------------------------------
                when Rserve =>
                -- 碰到左邊板子反彈
                    if (SQUARE_RIGHT = x - 50) and (y+50 >= SQUARE_TOP and y-49<= SQUARE_BOTTOM) then
                        move_left <= '0';
                -- 碰到右邊板子反彈
                    elsif (SQUARE_LEFT2 = x + 49) and (y+50 >= SQUARE_TOP2 and y-49 <= SQUARE_BOTTOM2) then
                        move_left <= '1';
                    end if;
                -- 碰到上下邊界反彈
                    if y + 50 >= C_V_ACTIVE_TIME then
                         move_up <= '0';
                    elsif y - 70 <= 0 then
                         move_up <= '1';
                    end if;     
                -- 移動球
                    if move_up = '1' then
                        y <= y + 1;
                    else
                        y <= y - 1;
                    end if;
                    if move_left = '1' then
                        x <= x - 1;
                    else
                        x <= x + 1;
                    end if;
                     if x-100<=0 then
                        cs<=Rsit;
                        Rcount<=Rcount+1;
                     elsif x>=750 then
                        cs<=Lsit;
                        Lcount<=Lcount+1;
                      end if;
                -------------------------------------------------------------------------
                      
             --------------------------------------------------------------------------------------------------
               when lsit =>
                    x<=130;
                    y<=240;
                    if SQUARE1_up='1' or SQUARE1_down='1' then
                         cs<=Lserve;
                    elsif Lcount>="011" or Rcount>="011" then
                        cs<=win;
                     end if;
             -------------------------------------------------------------------------------------------------------
               when Rsit =>
                    x<=520;
                    y<=240;
                    if SQUARE2_up='1' or SQUARE2_down='1' then
                         cs<=Rserve;
                    elsif Lcount>="011" or Rcount>="011" then
                        cs<=win;
                     end if;
            ---------------------------------------------------------------------------------------------------------
                when win=>
                    Lcount<= (others => '0');
                    Rcount<= (others => '0');
                    cs<=start;
              end case;
                 end if; 
    end process cir_process;
    o_Lcount<=Lcount;
    o_Rcount<=Rcount;
   ---------------------------板子移動
     SQUARE_process: process(cclk, reset, SQUARE1_up,SQUARE1_down,SQUARE2_up,SQUARE2_down)
    begin
        if reset = '1' then
            SQUARE_TOP     <= 190;
            SQUARE_BOTTOM  <= 290; 
            SQUARE_TOP2    <= 190;
            SQUARE_BOTTOM2  <= 290;
        elsif rising_edge(cclk) then
            if SQUARE1_up = '1' and SQUARE_BOTTOM < C_V_ACTIVE_TIME then
                SQUARE_TOP <= SQUARE_TOP + 2;
                SQUARE_BOTTOM <= SQUARE_BOTTOM + 2; 
            elsif SQUARE1_down = '1' and SQUARE_TOP > 0 then
                SQUARE_TOP <= SQUARE_TOP - 2;
                SQUARE_BOTTOM <= SQUARE_BOTTOM - 2; 
            end if;
            
            -- 方?2移?
            if SQUARE2_up = '1' and SQUARE_BOTTOM2 < C_V_ACTIVE_TIME then
                SQUARE_TOP2 <= SQUARE_TOP2 + 2;
                SQUARE_BOTTOM2 <= SQUARE_BOTTOM2 + 2;  
            elsif SQUARE2_down = '1' and SQUARE_TOP2 > 0 then
                SQUARE_TOP2 <= SQUARE_TOP2 - 2;
                SQUARE_BOTTOM2 <= SQUARE_BOTTOM2 - 2;               
            end if;
        end if;
    end process;

        
         -- 水平信??理
    horizontal_process: process(to_vga_clk, reset)
    begin
        if reset = '1' then
            R_h_cnt <= (others => '0');
        elsif rising_edge(to_vga_clk) then
            if R_h_cnt = C_H_LINE_PERIOD - 1 then
                R_h_cnt <= (others => '0');
            else
                R_h_cnt <= R_h_cnt + 1;
            end if;
        end if;
    end process horizontal_process;
    
    o_hs <= '0' when R_h_cnt < C_H_SYNC_PULSE else '1';
    
    -- 垂直信??理
    vertical_process: process(to_vga_clk, reset)
    begin
        if reset = '1' then
            R_v_cnt <= (others => '0');
        elsif rising_edge(to_vga_clk) then
            if R_v_cnt = C_V_FRAME_PERIOD - 1 then
                R_v_cnt <= (others => '0');
            elsif R_h_cnt = C_H_LINE_PERIOD - 1 then
                R_v_cnt <= R_v_cnt + 1;
            end if;
        end if;
    end process vertical_process;
    
    o_vs <= '0' when R_v_cnt < C_V_SYNC_PULSE else '1';
    
    W_active_flag <= '1' when (R_h_cnt >= (C_H_SYNC_PULSE + C_H_BACK_PORCH) and
                               R_h_cnt < (C_H_SYNC_PULSE + C_H_BACK_PORCH + C_H_ACTIVE_TIME) and
                               R_v_cnt >= (C_V_SYNC_PULSE + C_V_BACK_PORCH) and
                               R_v_cnt < (C_V_SYNC_PULSE + C_V_BACK_PORCH + C_V_ACTIVE_TIME)) else '0';
    pixel_x <= conv_integer(R_h_cnt) - (C_H_SYNC_PULSE +C_H_BACK_PORCH);
    pixel_y <= conv_integer(R_v_cnt) - (C_V_SYNC_PULSE + C_V_BACK_PORCH);
    -- VGA?出信??理 
                    
    vga_output: process(to_vga_clk, reset,W_active_flag,cclk,stop,o_Rcount,o_Lcount)
    begin
        if reset = '1' then
            dina <= (others => '0');
            o_red <= (others => '0');
            o_green <= (others => '0');
            o_blue <= (others => '0');
        elsif rising_edge(to_vga_clk) then 
            if W_active_flag = '1' then
                
                if pixel_x>=40 and pixel_x<=120 and pixel_y>=0 and pixel_y<=10 then
                  case o_Lcount is
                ------------------------------------------------------------------------------------------------------------------
                    when "001"=>
                        if pixel_x>=40 and pixel_x<=60 and pixel_y>=0 and pixel_y<=10 then
                              o_blue <= "1111";
                         else
                            o_blue <= "0000";
                         end if;
                    ------------------------------------------------------------------------------------------------------------------------  
                    when "010"=>
                        if pixel_x>=40 and pixel_x<=60 and pixel_y>=0 and pixel_y<=10 then
                            o_blue <= "1111";
                        elsif pixel_x>=70 and pixel_x<=90 and pixel_y>=0 and pixel_y<=10 then
                                o_blue <= "1111";
                        else
                               o_blue <= "0000";
                        end if;
               -----------------------------------------------------------------------------------------------------------------------------------------
               when "011"=>
                        if pixel_x>=100 and pixel_x<=120 and pixel_y>=0 and pixel_y<=10 then
                             o_blue <= "1111";
                        elsif pixel_x>=40 and pixel_x<=60 and pixel_y>=0 and pixel_y<=10 then
                             o_blue <= "1111";
                        elsif pixel_x>=70 and pixel_x<=90 and pixel_y>=0 and pixel_y<=10 then
                                o_blue <= "1111";
                                 else
                              o_blue <= "0000";
                         end if;
                                              
                  --------------------------------------------------------------------------------------------------------------          
                  when others =>
                    o_green <= "0000";
                  end case;
                  -------------------------------------------------------------------------------------------------------------------------
               elsif pixel_x>=540 and pixel_x<=620 and pixel_y>=0 and pixel_y<=10 then
                     case o_Rcount is
                ------------------------------------------------------------------------------------------------------------------
                    when "001"=>
                        if pixel_x>=600 and pixel_x<=620 and pixel_y>=0 and pixel_y<=10 then
                             o_green <= "1111";
                             else 
                              o_green <= "0000";
                         end if;
                       
                    ------------------------------------------------------------------------------------------------------------------------  
                    when "010"=>
                        if pixel_x>=600 and pixel_x<=620 and pixel_y>=0 and pixel_y<=10 then
                             o_green <= "1111";
                        elsif pixel_x>=570 and pixel_x<=590 and pixel_y>=0 and pixel_y<=10 then
                            o_green <= "1111";
                           else 
                              o_green <= "0000";
                         end if;
        
               -----------------------------------------------------------------------------------------------------------------------------------------
               when "011"=>
                     if pixel_x>=600 and pixel_x<=620 and pixel_y>=0 and pixel_y<=10 then
                             o_green <= "1111";
                        elsif pixel_x>=570 and pixel_x<=590 and pixel_y>=0 and pixel_y<=10 then
                            o_green <= "1111";
                        elsif pixel_x>=540 and pixel_x<=560 and pixel_y>=0 and pixel_y<=10 then
                            o_green <= "1111";
                           else 
                              o_green <= "0000";
                         end if;
                      
                  --------------------------------------------------------------------------------------------------------------          
                  when others =>
                     o_green <= "0000";
                  end case;
                 -------------------------------------------------------------------------------------------------------------------------------- 
                 
               elsif (pixel_x>=x-50 and pixel_x<=x+49) and (pixel_y >=y-50 and pixel_y<=y+49) then
                     RTL_wen<='1';
                    bram_addr<=bram_addr+1;
                     o_green <= "1111"-rtl_rdata(7 downto 4);
                     o_red <="1111"- rtl_rdata(7 downto 4);
                     o_blue <="1111"- rtl_rdata(7 downto 4);
               
              
                elsif (pixel_x=x+50 and pixel_y = y+50) then
                         RTL_wen<='0';
                    bram_addr<= (others => '0');
                    o_red <= (others => '0');
                    o_green <= (others => '0');
                    o_blue <= (others => '0');
                    
                    
                elsif (pixel_x<x-50 and pixel_x>x+49) and (pixel_y <y-50 and pixel_y>y+49) then
                    RTL_wen<='0';
                  ------------------------------------------------------------------------------------------------------------------------
                   
                elsif (pixel_x >= SQUARE_LEFT and pixel_x <= SQUARE_RIGHT and pixel_y >= SQUARE_TOP and pixel_y <= SQUARE_BOTTOM) then
                    if clocr_btn(1) = '1' then
                        o_blue <= "1111";
                    else
                        o_blue <= "0000";
                    end if;  
                    if clocr_btn(2) = '1' then
                        o_red <= "1111";
                    else
                        o_red <= "0000";
                    end if;
                    if clocr_btn(0) = '1' then
                        o_green <= "1111";
                    else
                        o_green <= "0000";
                    end if;
                elsif (pixel_x >= SQUARE_LEFT2 and pixel_x <= SQUARE_RIGHT2) and (pixel_y >= SQUARE_TOP2 and pixel_y <= SQUARE_BOTTOM2) then
                       if clocr_btn(1) = '1' then
                            o_blue <= "1111";
                        else
                            o_blue <= "0000";
                    end if;  
                    if clocr_btn(2) = '1' then
                        o_red <= "1111";
                    else
                        o_red <= "0000";
                    end if;
                    if clocr_btn(0) = '1' then
                        o_green <= "1111";
                    else
                        o_green <= "0000";
                    end if;
                else
                    o_red <= (others => '0');
                    o_green <= (others => '0');
                    o_blue <= (others => '0');
                      
            end if;
        end if;
        
        
          ---------------------
   end if;
     end process vga_output;
    
    
    ledout <= clocr_btn;
end Behavioral;
