--------------------------------------------------------------------------------
-- TEST BENCH FOR FIFO
-- JOHN CONVERTINO
-- NOTHING FANCY... JUST TEST..IES
-- OK MAYBE CONFIGS... MAYBE... BALLS
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

--------------------------------------------------------------------------------
-- FIFO PACKAGE FOR COMPONET STUFFS
--------------------------------------------------------------------------------
package package_fifo_stimulus is
  component read_fifo is
    GENERIC (
              BYTE_WIDTH : positive := 1;
              RAND_READ  : natural  := 0;
              FWFT       : natural  := 0;
              COUNT_WIDTH: positive := 5;
              AMT_TO_RD  : natural  := 0;
              THRESHOLD  : natural  := 0
            );
    PORT    (
              --read
              rd_data_count : in std_logic_vector(COUNT_WIDTH downto 0);
              rd_clk  : in  std_logic;
              rd_rstn : in  std_logic;
              rd_en   : out std_logic;
              rd_valid: in  std_logic;
              rd_data : in  std_logic_vector((BYTE_WIDTH*8)-1 downto 0);
              rd_empty: in  std_logic
            );
  end component read_fifo;
  
  component write_fifo is
    GENERIC (
              BYTE_WIDTH : positive := 1
            );
    PORT    (
              --write
              wr_clk  : in  std_logic;
              wr_rstn : in  std_logic;
              wr_en   : out std_logic;
              wr_ack  : in  std_logic;
              wr_data : out std_logic_vector((BYTE_WIDTH*8)-1 downto 0);
              wr_full : in  std_logic
            );
  end component write_fifo;
end package_fifo_stimulus;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

--------------------------------------------------------------------------------
-- FIFO READ ENTITY
--------------------------------------------------------------------------------
entity read_fifo is
  GENERIC (
            BYTE_WIDTH : positive := 1;
            RAND_READ  : natural  := 0;
            FWFT       : natural  := 0;
            COUNT_WIDTH: positive := 5;
            AMT_TO_RD  : natural  := 0;
            THRESHOLD  : natural  := 0
          );
  PORT    (
              --read
            rd_data_count : in std_logic_vector(COUNT_WIDTH downto 0);
            rd_clk  : in  std_logic;
            rd_rstn : in  std_logic;
            rd_en   : out std_logic;
            rd_valid: in  std_logic;
            rd_data : in  std_logic_vector((BYTE_WIDTH*8)-1 downto 0);
            rd_empty: in  std_logic
          );
end read_fifo;

architecture arch_read_fifo of read_fifo is
  signal rand_ready : std_logic_vector(31 downto 0) := (others => '1');
begin

  rnd : if (RAND_READ > 0) generate
    random : process
      variable seed1 : positive;
      variable seed2 : positive;
      variable rand  : real;
      variable rand_range : real := real(integer(2**10.0)-1);
    begin
      uniform(seed1, seed2, rand);
      rand_ready <= std_logic_vector(to_unsigned(integer(rand*rand_range), rand_ready'length));
      wait for 10 ns;
    end process;
  end generate rnd;
  
  process(rd_clk)
    variable rd_counter : integer;
  begin
    if(rising_edge(rd_clk)) then
      if(rd_rstn = '0') then
        rd_en <= '0';
        rd_counter := 0;
      else
        if(AMT_TO_RD = 0) then
          rd_en <= rand_ready(0) AND NOT(rd_empty);
          
          if((FWFT = 1) AND (rd_valid = '0')) then
            rd_en <= '0';
          end if;
        else
          rd_en <= '0';
          
          if(unsigned(rd_data_count) >= THRESHOLD) then
            if(rd_counter < AMT_TO_RD) then
              rd_counter := rd_counter + 1;
              rd_en <= '1';
            else
              rd_counter := 0;
            end if;
            
            
          end if;
        end if;
      end if;
    end if;
  end process;
end arch_read_fifo;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

--------------------------------------------------------------------------------
-- FIFO WRITE ENTITY
--------------------------------------------------------------------------------
entity write_fifo is
  GENERIC (
            BYTE_WIDTH : positive := 1
          );
  PORT    (
            --write
            wr_clk  : in  std_logic;
            wr_rstn : in  std_logic;
            wr_en   : out std_logic;
            wr_ack  : in  std_logic;
            wr_data : out std_logic_vector((BYTE_WIDTH*8)-1 downto 0);
            wr_full : in  std_logic
          );
end write_fifo;

-- write to the fifo all the time
architecture arch_write_fifo of write_fifo is
  signal reg_gen_wr_data : unsigned(wr_data'range);
  signal gen_wr_data     : unsigned(wr_data'range);
begin
  process(wr_clk)
  begin
    if(rising_edge(wr_clk)) then
      if(wr_rstn = '0') then
        wr_en <= '0';
        wr_data <= (others => '0');
        gen_wr_data <= (others => '1');
        
        reg_gen_wr_data <= (others => '1');
      else
        --fix me, double first data.
        wr_en <= NOT(wr_ack) AND NOT(wr_full);
        
        if((wr_full = '0') AND (wr_ack = '1')) then
          wr_en <= '1';
          
          gen_wr_data <= gen_wr_data + 1;
        end if;
        
        reg_gen_wr_data <= gen_wr_data;
        
        wr_data <= std_logic_vector(gen_wr_data);
        
        if(wr_full = '1') then
          gen_wr_data <= reg_gen_wr_data;
          reg_gen_wr_data <= reg_gen_wr_data;
          wr_data <= std_logic_vector(reg_gen_wr_data);
        end if;
      
      end if;
    end if;
  end process;
end arch_write_fifo;

-- write to the fifo all the time
architecture arch_write_fifo_decimate of write_fifo is
  signal reg_gen_wr_data : unsigned(wr_data'range);
  signal gen_wr_data     : unsigned(wr_data'range);
begin
  process(wr_clk)
  begin
    if(rising_edge(wr_clk)) then
      if(wr_rstn = '0') then
        wr_en <= '0';
        wr_data <= (others => '0');
        gen_wr_data <= (others => '1');
        
        reg_gen_wr_data <= (others => '1');
      else
        --fix me, double first data.
        wr_en <= NOT(wr_ack) AND NOT(wr_full);
        
        if((wr_full = '0') AND (wr_ack = '1')) then
          wr_en <= '1';
          
          gen_wr_data <= gen_wr_data + 1;
        end if;
        
        reg_gen_wr_data <= gen_wr_data;
        
        wr_data <= std_logic_vector(gen_wr_data);
        
        if(wr_full = '1') then
          gen_wr_data <= reg_gen_wr_data;
          reg_gen_wr_data <= reg_gen_wr_data;
          wr_data <= std_logic_vector(reg_gen_wr_data);
        end if;
      
      end if;
    end if;
  end process;
end arch_write_fifo_decimate;

-- write to the fifo once
architecture arch_write_fifo_once of write_fifo is
begin
  process(wr_clk)
    variable gen_wr_data : unsigned(7 downto 0);
    variable counter     : unsigned(7 downto 0);
  begin
    if(rising_edge(wr_clk)) then
      if(wr_rstn = '0') then
        wr_en <= '0';
        wr_data <= (others => '0');
        gen_wr_data := (others => '1');
        counter := (others => '0');
      else
        --fix me, double first data.
        wr_en <= '0';
        
        counter := counter + 1;
        
        if(counter >= 20) then
          counter := (others => '0');
          
          wr_en <= '1';
          
          wr_data <= std_logic_vector(gen_wr_data) & (23 downto 0 => '0');
          gen_wr_data := gen_wr_data - 1;
        end if;
      end if;
    end if;
  end process;
end arch_write_fifo_once;

-- write to the fifo pause, then repeat
architecture arch_write_fifo_pause_repeat of write_fifo is
  signal reg_gen_wr_data : unsigned(7 downto 0);
  signal gen_wr_data     : unsigned(7 downto 0);
begin
  process(wr_clk)
    variable delay_restart: unsigned(7 downto 0);
  begin
    if(rising_edge(wr_clk)) then
      if(wr_rstn = '0') then
        wr_en <= '0';
        wr_data <= (others => '0');
        gen_wr_data <= (others => '1');
        delay_restart := (others => '1');
                
        reg_gen_wr_data <= (others => '1');
      else
        --fix me, double first data.
        wr_en <= NOT(wr_ack) AND NOT(wr_full);
        
        if((gen_wr_data = 0) AND (wr_full = '0')) then
          wr_en   <= '0';
          wr_data <= (others => '0');
          
          delay_restart := delay_restart - 1;
          
          if(delay_restart = 0) then
            gen_wr_data <= (others => '1');
            delay_restart := (others => '1');
          end if;
        else 
          if((wr_full = '0') AND (wr_ack = '1')) then
            wr_en <= '1';
            
            gen_wr_data <= gen_wr_data - 1;
          end if;
          
          reg_gen_wr_data <= gen_wr_data;
          
          wr_data <= std_logic_vector(gen_wr_data) & (23 downto 0 => '0');
          
          if(wr_full = '1') then
            gen_wr_data <= reg_gen_wr_data;
            reg_gen_wr_data <= reg_gen_wr_data;
            wr_data <= std_logic_vector(reg_gen_wr_data) & (23 downto 0 => '0');
          end if;
        end if;
      end if;
    end if;
  end process;
end arch_write_fifo_pause_repeat;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use work.package_fifo_stimulus.all;

--------------------------------------------------------------------------------
-- FIFO TEST BENCH
--------------------------------------------------------------------------------
entity tb_fifo_cmp is
end tb_fifo_cmp;

architecture arch_tb_fifo of tb_fifo_cmp is
  --! 100 mhz @10ns clock rate (typical for axi devices)
  constant FIFO_RD_CLK_PERIOD         : time := 10 ns;
  constant FIFO_WR_CLK_PERIOD         : time := 10 ns;
  constant FIFO_RD_RESET_PERIOD       : time := 100 ns;
  constant FIFO_WR_RESET_PERIOD       : time := 100 ns;
  
  --! fifo constants
  constant c_FIFO_DEPTH : positive := 32;
  constant c_SYNC_DEPTH : natural  := 0;
  constant c_BYTE_WIDTH : positive := 4;
  constant c_FWFT       : natural  := 1;
  
  --! fifo signals
  -- clocks
  signal tb_rd_clk : std_logic := '1';
  signal tb_wr_clk : std_logic := '1';
  
  -- reset
  signal tb_rd_rstn : std_logic := '0';
  signal tb_wr_rstn : std_logic := '0';
  
  -- read signals
  signal tb_rd_en   : std_logic;
  signal tb_rd_valid: std_logic;
  signal tb_rd_data : std_logic_vector((c_BYTE_WIDTH*8)-1 downto 0);
  signal tb_rd_empty: std_logic;

  -- write signals
  signal tb_wr_en   : std_logic;
  signal tb_wr_ack  : std_logic;
  signal tb_wr_data : std_logic_vector((c_BYTE_WIDTH*8)-1 downto 0);
  signal tb_wr_full : std_logic;
  
  -- write xilinx signals
  signal tb_xilinx_wr_en   : std_logic;
  signal tb_xilinx_wr_ack  : std_logic;
  signal tb_xilinx_wr_data : std_logic_vector((c_BYTE_WIDTH*8)-1 downto 0);
  signal tb_xilinx_wr_full : std_logic;
  
  -- data count (doesn't do much right now)
  signal tb_data_count : std_logic_vector((integer(ceil(log2(real(c_FIFO_DEPTH))))) downto 0);
  
  signal tb_r_wr_en   : std_logic;
  signal tb_r_decimate: unsigned(0 downto 0);
  signal tb_r_wr_data : std_logic_vector((c_BYTE_WIDTH*8)-1 downto 0);
  
  signal tb_r_xilinx_wr_en   : std_logic;
  signal tb_r_xilinx_decimate: unsigned(0 downto 0);
  signal tb_r_xilinx_wr_data : std_logic_vector((c_BYTE_WIDTH*8)-1 downto 0);
  
  component util_fifo is
  GENERIC (
            FIFO_DEPTH : positive := 256;
            BYTE_WIDTH : positive := 1;
            COUNT_WIDTH: integer  := 8;
            FWFT       : natural  := 0;
            RD_SYNC_DEPTH : natural := 0;
            WR_SYNC_DEPTH : natural := 0;
            DC_SYNC_DEPTH : natural := 0;
            COUNT_DELAY   : natural := 1;
            COUNT_ENA     : natural := 1;
            DATA_ZERO     : natural := 0;
            ACK_ENA       : natural := 0;
            RAM_TYPE      : string  := "block"
          );
  PORT    (
            --! read interface
            rd_clk  : in  std_logic;
            rd_rstn : in  std_logic;
            rd_en   : in  std_logic;
            rd_valid: out std_logic;
            rd_data : out std_logic_vector((BYTE_WIDTH*8)-1 downto 0);
            rd_empty: out std_logic;
            --! write interface
            wr_clk  : in  std_logic;
            wr_rstn : in  std_logic;
            wr_en   : in  std_logic;
            wr_ack  : out std_logic;
            wr_data : in  std_logic_vector((BYTE_WIDTH*8)-1 downto 0);
            wr_full : out std_logic;
            --! data count interface
            data_count_clk  : in  std_logic;
            data_count_rstn : in  std_logic;
            data_count      : out std_logic_vector(COUNT_WIDTH downto 0)
          );
  end component;
  
begin

  UUT : component util_fifo
  generic map (
                FIFO_DEPTH => c_FIFO_DEPTH,
                BYTE_WIDTH => c_BYTE_WIDTH,
                RD_SYNC_DEPTH => 0,
                COUNT_WIDTH=> integer(ceil(log2(real(c_FIFO_DEPTH)))),
                COUNT_DELAY=> 0,
                DATA_ZERO  => 1,
                FWFT       => c_FWFT
              )
  port map    (
                --read
                rd_clk  => tb_rd_clk,
                rd_rstn => tb_rd_rstn,
                rd_en   => (tb_rd_en AND NOT(tb_rd_empty)),
                rd_valid=> tb_rd_valid,
                rd_data => tb_rd_data,
                rd_empty=> tb_rd_empty,
                --write
                wr_clk  => tb_wr_clk,
                wr_rstn => tb_wr_rstn,
                wr_en   => tb_wr_en,
                wr_ack  => tb_wr_ack,
                wr_data => tb_wr_data,
                wr_full => tb_wr_full,
                --data count
                data_count_clk  => tb_wr_clk,
                data_count_rstn => tb_wr_rstn,
                data_count      => tb_data_count
              );

  READ_STIM : component read_fifo
  port map    (
                --read
                rd_data_count => tb_data_count,
                rd_clk  => tb_rd_clk,
                rd_rstn => tb_rd_rstn,
                rd_en   => tb_rd_en,
                rd_valid=> tb_rd_valid,
                rd_data => tb_rd_data,
                rd_empty=> tb_rd_empty
              );
              
  WRITE_STIM : component write_fifo
  port map    (
                --write
                wr_clk  => tb_wr_clk,
                wr_rstn => tb_wr_rstn,
                wr_en   => tb_wr_en,
                wr_ack  => '1',
                wr_data => tb_wr_data,
                wr_full => tb_wr_full
              );
              

  decimate_util_fifo: process(tb_wr_clk)
  begin
    if(rising_edge(tb_wr_clk)) then
      if(tb_wr_rstn = '0') then
        tb_r_wr_en <= '0';
        tb_r_decimate <= (others => '0');
        tb_r_wr_data <= (others => '0');
      else
        if((tb_wr_full = '0') AND ((tb_wr_en = '1') OR (tb_r_wr_en = '1'))) then
          tb_r_wr_data  <= tb_wr_data;
          tb_r_wr_en    <= std_logic(tb_r_decimate(0));
          tb_r_decimate <= tb_r_decimate + 1;
        end if;
        
--         tb_r_decimate(0) <= tb_wr_en;
      end if;
    end if;
  end process;
  
  decimate_xilinx_fifo: process(tb_wr_clk)
  begin
    if(rising_edge(tb_wr_clk)) then
      if(tb_wr_rstn = '0') then
        tb_r_xilinx_wr_en <= '0';
        tb_r_xilinx_decimate <= (others => '0');
        tb_r_xilinx_wr_data <= (others => '0');
      else
        if((tb_xilinx_wr_full = '0') AND (tb_xilinx_wr_en = '1')) then
          tb_r_xilinx_wr_data <= tb_xilinx_wr_data;
          tb_r_xilinx_wr_en   <= std_logic(tb_r_xilinx_decimate(0));
          tb_r_xilinx_decimate<= tb_r_xilinx_decimate + 1;
        end if;
      end if;
    end if;
  end process;
  
  -- clock
  tb_rd_clk   <= not tb_rd_clk after FIFO_RD_CLK_PERIOD/2;
  tb_wr_clk   <= not tb_wr_clk after FIFO_WR_CLK_PERIOD/2;
  -- reset
  tb_rd_rstn  <= '1' after FIFO_RD_RESET_PERIOD;
  tb_wr_rstn  <= '1' after FIFO_WR_RESET_PERIOD;
  
end arch_tb_fifo;

configuration empty_test of tb_fifo_cmp is
  for arch_tb_fifo
    for READ_STIM : read_fifo
      use entity work.read_fifo(arch_read_fifo)
        generic map (
                      BYTE_WIDTH => c_BYTE_WIDTH,
                      RAND_READ  => 0,
                      FWFT       => c_FWFT
                    );
    end for;
    
    for WRITE_STIM : write_fifo
      use entity work.write_fifo(arch_write_fifo_pause_repeat)
        generic map (
                      BYTE_WIDTH => c_BYTE_WIDTH
                    );
    end for;
  end for;
end empty_test;

configuration full_test of tb_fifo_cmp is
  for arch_tb_fifo
    for READ_STIM : read_fifo
      use entity work.read_fifo(arch_read_fifo)
        generic map (
                      BYTE_WIDTH => c_BYTE_WIDTH,
                      RAND_READ  => 1,
                      FWFT       => c_FWFT
                    );
    end for;
    
    for WRITE_STIM : write_fifo
      use entity work.write_fifo(arch_write_fifo)
        generic map (
                      BYTE_WIDTH => c_BYTE_WIDTH
                    );
    end for;
  end for;
end full_test;

configuration norm_test of tb_fifo_cmp is
  for arch_tb_fifo
    for READ_STIM : read_fifo
      use entity work.read_fifo(arch_read_fifo)
        generic map (
                      BYTE_WIDTH => c_BYTE_WIDTH,
                      RAND_READ  => 0,
                      FWFT       => 0
                    );
    end for;
    
    for WRITE_STIM : write_fifo
      use entity work.write_fifo(arch_write_fifo)
        generic map (
                      BYTE_WIDTH => c_BYTE_WIDTH
                    );
    end for;
  end for;
end norm_test;

configuration fwft_test of tb_fifo_cmp is
  for arch_tb_fifo
    for READ_STIM : read_fifo
      use entity work.read_fifo(arch_read_fifo)
        generic map (
                      BYTE_WIDTH => c_BYTE_WIDTH,
                      RAND_READ  => 0,
                      FWFT       => 1
                    );
    end for;
    
    for WRITE_STIM : write_fifo
      use entity work.write_fifo(arch_write_fifo_once)
        generic map (
                      BYTE_WIDTH => c_BYTE_WIDTH
                    );
    end for;
  end for;
end fwft_test;

configuration write_once_test of tb_fifo_cmp is
  for arch_tb_fifo
    for READ_STIM : read_fifo
      use entity work.read_fifo(arch_read_fifo)
        generic map (
                      BYTE_WIDTH => c_BYTE_WIDTH,
                      RAND_READ  => 0,
                      FWFT       => c_FWFT,
                      COUNT_WIDTH=> integer(ceil(log2(real(c_FIFO_DEPTH)))),
                      AMT_TO_RD  => 1,
                      THRESHOLD  => 2
                    );
    end for;
    
    for WRITE_STIM : write_fifo
      use entity work.write_fifo(arch_write_fifo_once)
        generic map (
                      BYTE_WIDTH => c_BYTE_WIDTH
                    );
    end for;
  end for;
end write_once_test;
