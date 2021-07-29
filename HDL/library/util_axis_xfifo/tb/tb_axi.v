--------------------------------------------------------------------------------
--! @file   tb_axi.vhd
--! @author John Convertino(electrobs@gmail.com)
--! @date   2020.05.11
--! @brief  Unit under test
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
--package so we don't have to do a component declare in this file
use work.package_axi_stimulus.all;

entity tb_axi is
--nothing this is a test bench, not a sandwich
end tb_axi;

architecture arch_tb_axi of tb_axi is
  --! 100 mhz @10ns clock rate (typical for axi devices)
  constant S_CLOCK_PERIOD         : time := 10 ns;
  constant M_CLOCK_PERIOD         : time := 10 ns;
  constant STREAMING_RESET_PERIOD : time := 100 ns;
  
  --! UUT means the unit under test. Signal TB_UUT_S_BUS_WIDTH is the
  --! unit under test's slave axi streaming bus width.
  constant TB_UUT_AXI_ADDRESS_WIDTH : positive := 16;
  constant TB_UUT_S_BUS_WIDTH   : positive := 8;
  constant TB_UUT_M_BUS_WIDTH   : positive := 8;
  constant TB_UUT_S_USER_WIDTH  : positive := 1;
  constant TB_UUT_M_USER_WIDTH  : positive := 1;
  constant TB_UUT_DEST_WIDTH    : positive := 4;
  
  constant TB_UUT_FILE_OUT      : string := "fileout.txt";
  constant TB_UUT_FILE_IN       : string := "filein.txt";

  --! clock and reset signals
  signal tb_s_aclk    : std_logic := '1';
  signal tb_m_aclk    : std_logic := '1';
  signal tb_arstn     : std_logic := '0';
  
  --! axi slave streaming signals
  signal tb_uut_s_axis_tdata : std_logic_vector((8*TB_UUT_S_BUS_WIDTH-1) downto 0) := (others => '0');
  signal tb_uut_s_axis_tkeep : std_logic_vector((TB_UUT_S_BUS_WIDTH-1) downto 0)   := (others => '0');
  signal tb_uut_s_axis_tstrb : std_logic_vector((TB_UUT_S_BUS_WIDTH-1) downto 0)   := (others => '0');
  signal tb_uut_s_axis_tuser : std_logic_vector(TB_UUT_S_USER_WIDTH-1 downto 0)    := (others => '1');
  signal tb_uut_s_axis_tdest : std_logic_vector(TB_UUT_DEST_WIDTH-1 downto 0)      := (others => '1');
  signal tb_uut_s_axis_tvalid: std_logic := '0';
  signal tb_uut_s_axis_tlast : std_logic := '0';
  signal tb_uut_s_axis_tready: std_logic := '0';
  --! axis master streaming signals
  signal tb_uut_m_axis_tdata : std_logic_vector((8*TB_UUT_M_BUS_WIDTH-1) downto 0) := (others => '0');
  signal tb_uut_m_axis_tkeep : std_logic_vector((TB_UUT_M_BUS_WIDTH-1) downto 0)   := (others => '0');
  signal tb_uut_m_axis_tstrb : std_logic_vector((TB_UUT_M_BUS_WIDTH-1) downto 0)   := (others => '0');
  signal tb_uut_m_axis_tuser : std_logic_vector(TB_UUT_M_USER_WIDTH-1 downto 0)    := (others => '0');
  signal tb_uut_m_axis_tdest : std_logic_vector(TB_UUT_DEST_WIDTH-1 downto 0)      := (others => '1');
  signal tb_uut_m_axis_tvalid: std_logic := '0';
  signal tb_uut_m_axis_tlast : std_logic := '0';
  signal tb_uut_m_axis_tready: std_logic := '0';
  
  component util_axis_xfifo is
  GENERIC (
            FIFO_DEPTH : positive := 256;
            COUNT_WIDTH: positive := 8;
            BUS_WIDTH  : positive := 1;
            USER_WIDTH : positive := 1;
            DEST_WIDTH : positive := 1;
            RAM_TYPE   : string   := "";
            PACKET_MODE: natural  := 0;
            COUNT_DELAY: natural  := 1;
            COUNT_ENA  : natural  := 1
          );
  PORT    (
            --read
            m_axis_aclk  : in  std_logic;
            m_axis_arstn : in  std_logic;
            m_axis_tvalid: out std_logic;
            m_axis_tready: in  std_logic;
            m_axis_tdata : out std_logic_vector((BUS_WIDTH*8)-1 downto 0);
            m_axis_tkeep : out std_logic_vector(BUS_WIDTH-1 downto 0);
            m_axis_tlast : out std_logic;
            m_axis_tuser : out std_logic_vector(USER_WIDTH-1 downto 0);
            m_axis_tdest : out std_logic_vector(DEST_WIDTH-1 downto 0);
            --write
            s_axis_aclk  : in  std_logic;
            s_axis_arstn : in  std_logic;
            s_axis_tvalid: in  std_logic;
            s_axis_tready: out std_logic;
            s_axis_tdata : in  std_logic_vector((BUS_WIDTH*8)-1 downto 0);
            s_axis_tkeep : in  std_logic_vector(BUS_WIDTH-1 downto 0);
            s_axis_tlast : in  std_logic;
            s_axis_tuser : in  std_logic_vector(USER_WIDTH-1 downto 0);
            s_axis_tdest : in  std_logic_vector(DEST_WIDTH-1 downto 0);
            --data count
            data_count_aclk : in std_logic;
            data_count_arstn: in std_logic;
            data_count : out std_logic_vector(COUNT_WIDTH downto 0)
          );
  end component;

begin
  -- for Verilog
  uut : component util_axis_xfifo
  generic map(
                --! slave bus size in bytes
                FIFO_DEPTH => 2048,
                USER_WIDTH => TB_UUT_S_USER_WIDTH,
                DEST_WIDTH => TB_UUT_DEST_WIDTH,
                BUS_WIDTH  => TB_UUT_S_BUS_WIDTH,
                PACKET_MODE=> 1
             )
  port map   (
                  s_axis_aclk => tb_s_aclk,
                  m_axis_aclk => tb_m_aclk,
                  s_axis_arstn => tb_arstn,
                  m_axis_arstn => tb_arstn,
                  --! slave axis streaming interface
                  s_axis_tdata => tb_uut_s_axis_tdata,
                  s_axis_tkeep => tb_uut_s_axis_tkeep,
                  s_axis_tdest => tb_uut_s_axis_tdest,
                  s_axis_tvalid=> tb_uut_s_axis_tvalid,
                  s_axis_tlast => tb_uut_s_axis_tlast,
                  s_axis_tuser => tb_uut_s_axis_tuser,
                  s_axis_tready=> tb_uut_s_axis_tready,
                  --! master axis streaming interface
                  m_axis_tdata => tb_uut_m_axis_tdata,
                  m_axis_tkeep => tb_uut_m_axis_tkeep,
                  m_axis_tdest => tb_uut_m_axis_tdest,
                  m_axis_tvalid=> tb_uut_m_axis_tvalid,
                  m_axis_tlast => tb_uut_m_axis_tlast,
                  m_axis_tuser => tb_uut_m_axis_tuser,
                  m_axis_tready=> tb_uut_m_axis_tready,
                  --! data_count
                  data_count_aclk => tb_s_aclk,
                  data_count_arstn=> tb_arstn,
                  data_count => open
                );

  master_stimulus : component axi_streaming_master_stimulus
    port map  (
                arstn       => tb_arstn,
                s_axis_aclk	=> tb_m_aclk,
                --! slave axi streaming interface
                s_axis_tdata => tb_uut_m_axis_tdata,
                s_axis_tkeep => tb_uut_m_axis_tkeep,
                s_axis_tstrb => tb_uut_m_axis_tstrb,
                s_axis_tuser => tb_uut_m_axis_tuser,
                s_axis_tvalid=> tb_uut_m_axis_tvalid,
                s_axis_tlast => tb_uut_m_axis_tlast,
                s_axis_tready=> tb_uut_m_axis_tready
              );
              
  slave_stimulus : component axi_streaming_slave_stimulus
    port map  (
                arstn       => tb_arstn,
                m_axis_aclk	=> tb_s_aclk,
                --! master axi streaming interface
                m_axis_tdata => tb_uut_s_axis_tdata,
                m_axis_tkeep => tb_uut_s_axis_tkeep,
                m_axis_tstrb => tb_uut_s_axis_tstrb,
                m_axis_tuser => tb_uut_s_axis_tuser,
                m_axis_tvalid=> tb_uut_s_axis_tvalid,
                m_axis_tlast => tb_uut_s_axis_tlast,
                m_axis_tready=> tb_uut_s_axis_tready
              );

--! clock and reset
  tb_s_aclk   <= not tb_s_aclk  after S_CLOCK_PERIOD/2;
  tb_m_aclk   <= not tb_m_aclk  after M_CLOCK_PERIOD/2;
  tb_arstn    <= '1' after STREAMING_RESET_PERIOD;

end arch_tb_axi;

configuration cfg_read_file_base_2 of tb_axi is
  for arch_tb_axi
    for slave_stimulus : axi_streaming_slave_stimulus
      use entity work.axi_streaming_slave_stimulus(read_file)
        generic map (
          M_BUS_WIDTH => TB_UUT_S_BUS_WIDTH,
          M_USER_WIDTH=> TB_UUT_S_USER_WIDTH,
          FILE_NAME   => TB_UUT_FILE_IN,
          FILE_BASE   => 2,
          CONST_DATA  => 16#FF#,
          COUNT_AMT   => 100
        );
    end for;
    
    for master_stimulus : axi_streaming_master_stimulus
      use entity work.axi_streaming_master_stimulus(hex_dump)
        generic map (
          S_BUS_WIDTH => TB_UUT_S_BUS_WIDTH,
          S_USER_WIDTH=> TB_UUT_S_USER_WIDTH,
          FILE_NAME   => TB_UUT_FILE_OUT,
          FILE_BASE   => 2,
          RND_READY   => '0'
        );
    end for;
  end for;
end cfg_read_file_base_2;

configuration cfg_read_file_base_16 of tb_axi is
  for arch_tb_axi
    for slave_stimulus : axi_streaming_slave_stimulus
      use entity work.axi_streaming_slave_stimulus(read_file)
        generic map (
          M_BUS_WIDTH => TB_UUT_S_BUS_WIDTH,
          M_USER_WIDTH=> TB_UUT_S_USER_WIDTH,
          FILE_NAME   => TB_UUT_FILE_IN,
          FILE_BASE   => 16,
          CONST_DATA  => 16#FF#,
          COUNT_AMT   => 100
        );
    end for;
    
    for master_stimulus : axi_streaming_master_stimulus
      use entity work.axi_streaming_master_stimulus(hex_dump)
        generic map (
          S_BUS_WIDTH => TB_UUT_S_BUS_WIDTH,
          S_USER_WIDTH=> TB_UUT_S_USER_WIDTH,
          FILE_NAME   => TB_UUT_FILE_OUT,
          FILE_BASE   => 16,
          RND_READY   => '0'
        );
    end for;
  end for;
end cfg_read_file_base_16;

configuration cfg_rand_ready_read_file_base_16 of tb_axi is
  for arch_tb_axi
    for slave_stimulus : axi_streaming_slave_stimulus
      use entity work.axi_streaming_slave_stimulus(read_file)
        generic map (
          M_BUS_WIDTH => TB_UUT_S_BUS_WIDTH,
          M_USER_WIDTH=> TB_UUT_S_USER_WIDTH,
          FILE_NAME   => TB_UUT_FILE_IN,
          FILE_BASE   => 16
        );
    end for;
    
    for master_stimulus : axi_streaming_master_stimulus
      use entity work.axi_streaming_master_stimulus(hex_dump)
        generic map (
          S_BUS_WIDTH => TB_UUT_S_BUS_WIDTH,
          S_USER_WIDTH=> TB_UUT_S_USER_WIDTH,
          FILE_NAME   => TB_UUT_FILE_OUT,
          FILE_BASE   => 16,
          RND_READY   => '1'
        );
    end for;
  end for;
end cfg_rand_ready_read_file_base_16;

configuration cfg_const_data of tb_axi is
  for arch_tb_axi
    for slave_stimulus : axi_streaming_slave_stimulus
      use entity work.axi_streaming_slave_stimulus(const_data)
        generic map (
          M_BUS_WIDTH => TB_UUT_S_BUS_WIDTH,
          M_USER_WIDTH=> TB_UUT_S_USER_WIDTH,
          CONST_DATA  => 16#FF#
        );
    end for;
    
    for master_stimulus : axi_streaming_master_stimulus
      use entity work.axi_streaming_master_stimulus(hex_dump)
        generic map (
          S_BUS_WIDTH => TB_UUT_S_BUS_WIDTH,
          S_USER_WIDTH=> TB_UUT_S_USER_WIDTH,
          FILE_NAME   => TB_UUT_FILE_OUT,
          FILE_BASE   => 16
        );
    end for;
  end for;
end cfg_const_data;

configuration cfg_const_data_rand_ready of tb_axi is
  for arch_tb_axi
    for slave_stimulus : axi_streaming_slave_stimulus
      use entity work.axi_streaming_slave_stimulus(const_data)
        generic map (
          M_BUS_WIDTH => TB_UUT_S_BUS_WIDTH,
          M_USER_WIDTH=> TB_UUT_S_USER_WIDTH,
          CONST_DATA  => 16#FF#
        );
    end for;
    
    for master_stimulus : axi_streaming_master_stimulus
      use entity work.axi_streaming_master_stimulus(hex_dump)
        generic map (
          S_BUS_WIDTH => TB_UUT_S_BUS_WIDTH,
          S_USER_WIDTH=> TB_UUT_S_USER_WIDTH,
          FILE_NAME   => TB_UUT_FILE_OUT,
          FILE_BASE   => 16,
          RND_READY   => '1'
        );
    end for;
  end for;
end cfg_const_data_rand_ready;

configuration cfg_repeat_counter of tb_axi is
  for arch_tb_axi
    for slave_stimulus : axi_streaming_slave_stimulus
      use entity work.axi_streaming_slave_stimulus(repeat_counter)
        generic map (
          M_BUS_WIDTH => TB_UUT_S_BUS_WIDTH,
          M_USER_WIDTH=> TB_UUT_S_USER_WIDTH,
          COUNT_AMT   => 100
        );
    end for;
    
    for master_stimulus : axi_streaming_master_stimulus
      use entity work.axi_streaming_master_stimulus(hex_dump)
        generic map (
          S_BUS_WIDTH => TB_UUT_S_BUS_WIDTH,
          S_USER_WIDTH=> TB_UUT_S_USER_WIDTH,
          FILE_NAME   => TB_UUT_FILE_OUT,
          FILE_BASE   => 16
        );
    end for;
  end for;
end cfg_repeat_counter;

configuration cfg_rand_ready_repeat_counter of tb_axi is
  for arch_tb_axi
    for slave_stimulus : axi_streaming_slave_stimulus
      use entity work.axi_streaming_slave_stimulus(repeat_counter)
        generic map (
          M_BUS_WIDTH => TB_UUT_S_BUS_WIDTH,
          M_USER_WIDTH=> TB_UUT_S_USER_WIDTH,
          COUNT_AMT   => 100
        );
    end for;
    
    for master_stimulus : axi_streaming_master_stimulus
      use entity work.axi_streaming_master_stimulus(hex_dump)
        generic map (
          S_BUS_WIDTH => TB_UUT_S_BUS_WIDTH,
          S_USER_WIDTH=> TB_UUT_S_USER_WIDTH,
          FILE_NAME   => TB_UUT_FILE_OUT,
          FILE_BASE   => 16,
          RND_READY   => '1'
        );
    end for;
  end for;
end cfg_rand_ready_repeat_counter;

configuration cfg_rand_ready_pause_repeat_counter of tb_axi is
  for arch_tb_axi
    for slave_stimulus : axi_streaming_slave_stimulus
      use entity work.axi_streaming_slave_stimulus(pause_repeat_counter)
        generic map (
          M_BUS_WIDTH => TB_UUT_S_BUS_WIDTH,
          M_USER_WIDTH=> TB_UUT_S_USER_WIDTH,
          COUNT_AMT   => 100
        );
    end for;
    
    for master_stimulus : axi_streaming_master_stimulus
      use entity work.axi_streaming_master_stimulus(hex_dump)
        generic map (
          S_BUS_WIDTH => TB_UUT_S_BUS_WIDTH,
          S_USER_WIDTH=> TB_UUT_S_USER_WIDTH,
          FILE_NAME   => TB_UUT_FILE_OUT,
          FILE_BASE   => 16,
          RND_READY   => '1'
        );
    end for;
  end for;
end cfg_rand_ready_pause_repeat_counter;
