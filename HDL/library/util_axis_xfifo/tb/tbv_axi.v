--------------------------------------------------------------------------------
--! @file   tbv_axi.vhd
--! @author John Convertino(electrobs@gmail.com)
--! @date   2020.01.31
--! @brief  Entity and different architectures for test bench stimulus component
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package package_axi_stimulus is
  component axi_lite_slave_stimulus is
    generic (
              AXI_ADDRESS_WIDTH : positive := 16
            );
    port    (
              arstn         : in std_logic;
              s_axi_aclk    : in std_logic;
              --! Address to write too
              awvalid       : out std_logic;
              awaddr        : out std_logic_vector(AXI_ADDRESS_WIDTH-1 downto 0);
              awready       : in  std_logic;
              --! Data to write to address
              wvalid        : out std_logic;
              wdata         : out std_logic_vector(31 downto 0);
              wstrb         : out std_logic_vector(3 downto 0);
              wready        : in  std_logic;
              --! data write status
              bvalid        : in  std_logic;
              bresp         : in  std_logic_vector(1 downto 0);
              bready        : out std_logic;
              --! Address to read from
              arvalid       : out std_logic;
              araddr        : out std_logic_vector(AXI_ADDRESS_WIDTH-1 downto 0);
              arready       : in  std_logic;
              --! Data to read from address
              rvalid        : in  std_logic;
              rresp         : in  std_logic_vector(1 downto 0);
              rdata         : in  std_logic_vector(31 downto 0);
              rready        : out std_logic
            );
  end component axi_lite_slave_stimulus;
  
  component axi_streaming_slave_stimulus is
    generic (
              --! slave bus size in bytes
              M_BUS_WIDTH : positive  := 8;
              --! User width in bits
              M_USER_WIDTH : positive := 1;
              --! constant data word to output
              CONST_DATA  : integer   := 16#FF#;
              --! File input name (TXT only)
              FILE_NAME   : string    := "input.txt";
              --! File input base in AND out
              FILE_BASE   : natural   := 2;
              --! Amount to count to and then rollover.
              COUNT_AMT   : positive  := 100
            );
    port    (
              arstn        : in std_logic;
              m_axis_aclk  : in std_logic;
              --! master axi streaming interface
              m_axis_tdata : out std_logic_vector((8*M_BUS_WIDTH-1) downto 0);
              m_axis_tkeep : out std_logic_vector((M_BUS_WIDTH-1) downto 0);
              m_axis_tstrb : out std_logic_vector((M_BUS_WIDTH-1) downto 0);
              m_axis_tuser : out std_logic_vector(M_USER_WIDTH-1 downto 0);
              m_axis_tvalid: out std_logic;
              m_axis_tlast : out std_logic;
              m_axis_tready: in std_logic
            );
  end component axi_streaming_slave_stimulus;
  
  component axi_streaming_master_stimulus is
    generic (
              --! slave bus size in bytes
              S_BUS_WIDTH : positive  := 8;
              --! User width in bits
              S_USER_WIDTH: positive := 1;
              --! File output name (TXT only)
              FILE_NAME   : string    := "output.txt";
              --! File input base in AND out
              FILE_BASE   : natural   := 2;
              --! Randomize the ready signal to the unit under test.
              RND_READY   : std_logic := '0'
            );
    port    (
              arstn        : in std_logic;
              s_axis_aclk  : in std_logic;
              --! slave axi streaming interface
              s_axis_tdata : in std_logic_vector((8*S_BUS_WIDTH-1) downto 0);
              s_axis_tkeep : in std_logic_vector((S_BUS_WIDTH-1) downto 0);
              s_axis_tstrb : in std_logic_vector((S_BUS_WIDTH-1) downto 0);
              s_axis_tuser : in std_logic_vector(S_USER_WIDTH-1 downto 0);
              s_axis_tvalid: in std_logic;
              s_axis_tlast : in std_logic;
              s_axis_tready: out std_logic
            );
  end component axi_streaming_master_stimulus;
end package_axi_stimulus;

--! Axi lite stimulus component
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_textio.all;
use IEEE.math_real.all;
--std text io
use std.textio.all;

entity axi_lite_slave_stimulus is
  generic (
            AXI_ADDRESS_WIDTH : positive := 16
          );
  port    (
            arstn         : in std_logic;
            s_axi_aclk    : in std_logic;
            --! Address to write too
            awvalid       : out std_logic;
            awaddr        : out std_logic_vector(AXI_ADDRESS_WIDTH-1 downto 0);
            awready       : in  std_logic;
            --! Data to write to address
            wvalid        : out std_logic;
            wdata         : out std_logic_vector(31 downto 0);
            wstrb         : out std_logic_vector(3 downto 0);
            wready        : in  std_logic;
            --! data write status
            bvalid        : in  std_logic;
            bresp         : in  std_logic_vector(1 downto 0);
            bready        : out std_logic;
            --! Address to read from
            arvalid       : out std_logic;
            araddr        : out std_logic_vector(AXI_ADDRESS_WIDTH-1 downto 0);
            arready       : in  std_logic;
            --! Data to read from address
            rvalid        : in  std_logic;
            rresp         : in  std_logic_vector(1 downto 0);
            rdata         : in  std_logic_vector(31 downto 0);
            rready        : out std_logic
          );
end axi_lite_slave_stimulus;

architecture read_only of axi_lite_slave_stimulus is
  signal r_rresp : std_logic_vector(1 downto 0);
  signal r_rdata : std_logic_vector(31 downto 0);
  
  type st_state is (idle, ready);
  signal s_state : st_state := idle;
begin
  consumer : process(s_axi_aclk)
    variable counter : unsigned(AXI_ADDRESS_WIDTH-1 downto 0);
  begin
    if(rising_edge(s_axi_aclk)) then
      if(arstn = '0') then
        awvalid <= '0';
        awaddr  <= (others => '0');
        
        wvalid  <= '0';
        wdata   <= (others => '0');
        wstrb   <= (others => '0');
      
        bready  <= '0';
      
        arvalid <= '0';
        araddr  <= (others => '0');
        
        rready  <= '0';
        
        r_rresp <= (others => '0');
        r_rdata <= (others => '0');
        
        counter := (others => '0');
        
        s_state <= idle;
      else
        rready <= '1';
        
        case s_state is
          when idle =>
            s_state <= ready;
            
            araddr  <= std_logic_vector(counter);
            arvalid <= '1';
            counter := counter + 1;
          when ready=>
            s_state <= ready;
            
            if(arready = '1') then
              araddr  <= std_logic_vector(counter);
              arvalid <= '1';
              counter := counter + 1;
            end if;
            
            if(rvalid = '1') then
              r_rresp <= rresp;
              r_rdata <= rdata;
            end if;
        end case;
      end if;
    end if;
  end process;
end read_only;

architecture write_only of axi_lite_slave_stimulus is
  signal r_rresp : std_logic_vector(1 downto 0);
  signal r_rdata : std_logic_vector(31 downto 0);
  
  type st_state is (idle, ready);
  signal s_state : st_state := idle;
begin
  consumer : process(s_axi_aclk)
    variable counter : unsigned(AXI_ADDRESS_WIDTH-1 downto 0);
  begin
    if(rising_edge(s_axi_aclk)) then
      if(arstn = '0') then
        awvalid <= '0';
        awaddr  <= (others => '0');
        
        wvalid  <= '0';
        wdata   <= (others => '0');
        wstrb   <= (others => '0');
      
        bready  <= '0';
      
        arvalid <= '0';
        araddr  <= (others => '0');
        
        rready  <= '0';
        
        r_rresp <= (others => '0');
        r_rdata <= (others => '0');
        
        counter := (others => '0');
        
        s_state <= idle;
      else
        bready <= '1';
        --bresp all 0's is "ok" response
        case s_state is
          when idle =>
            s_state <= ready;
            
            -- assert address
            awaddr  <= std_logic_vector(counter);
            awvalid <= '1';
            counter := counter + 1;
            
            -- assert data
            wvalid  <= '1';
            wdata   <= std_logic_vector(to_unsigned(16#DEAD#, wdata'length));
            wstrb   <= (others => '1');
          when ready=>
            s_state <= ready;
            
            if(awready = '1') then
              awaddr  <= std_logic_vector(counter);
              awvalid <= '1';
              counter := counter + 1;
            end if;
            
            if(wready = '1') then
              wvalid  <= '1';
              wdata   <= std_logic_vector(to_unsigned(16#DEAD#, wdata'length));
              wstrb   <= (others => '1');
            end if;
        end case;
      end if;
    end if;
  end process;
end write_only;

--! Axi streaming slave stimulus component
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_textio.all;
use IEEE.math_real.all;
--std text io
use std.textio.all;

entity axi_streaming_slave_stimulus is
  generic (
            --! slave bus size in bytes
            M_BUS_WIDTH : positive  := 8;
            --! User width in bits
            M_USER_WIDTH : positive := 1;
            --! constant data word to output
            CONST_DATA  : integer   := 16#FF#;
            --! File input name (TXT only)
            FILE_NAME   : string    := "input.txt";
            --! File input base in AND out
            FILE_BASE   : natural   := 2;
            --! Amount to count to and then rollover.
            COUNT_AMT   : positive  := 100
          );
  port    (
            arstn        : in std_logic;
            m_axis_aclk  : in std_logic;
            --! master axi streaming interface
            m_axis_tdata : out std_logic_vector((8*M_BUS_WIDTH-1) downto 0);
            m_axis_tkeep : out std_logic_vector((M_BUS_WIDTH-1) downto 0);
            m_axis_tstrb : out std_logic_vector((M_BUS_WIDTH-1) downto 0);
            m_axis_tuser : out std_logic_vector(M_USER_WIDTH-1 downto 0);
            m_axis_tvalid: out std_logic;
            m_axis_tlast : out std_logic;
            m_axis_tready: in std_logic
          );
end axi_streaming_slave_stimulus;

architecture read_file of axi_streaming_slave_stimulus is
  file fileD : text;
  
  type st_pro_state_machine is (idle, ready, done);
  signal pro_state_machine : st_pro_state_machine;
begin
  producer : process(m_axis_aclk, arstn)
    variable fileD_line : line;
    variable file_data  : std_logic_vector(m_axis_tdata'range);
    variable first_push : std_logic := '0';
  begin
    if(arstn = '0') then
      --reset
      m_axis_tvalid <= '0';
      m_axis_tlast  <= '0';
      m_axis_tuser  <= (others => '0');
      m_axis_tdata  <= (others => '0');
      m_axis_tkeep  <= (others => '0');
      m_axis_tstrb  <= (others => '0');
      pro_state_machine <= idle;
    elsif(rising_edge(m_axis_aclk)) then
      case pro_state_machine is
        when idle  =>
          pro_state_machine <= idle;
          
          file_open(fileD, FILE_NAME, read_mode);
          
          if(NOT endfile(fileD)) then
            pro_state_machine <= ready;
            
            readline(fileD, fileD_line);
            m_axis_tdata  <= file_data;
            m_axis_tvalid <= '1';
            m_axis_tkeep  <= (others => '1');
            case FILE_BASE is
              when 2 =>
                read(fileD_line, file_data);
              when 16=>
                hread(fileD_line, file_data);
              when others=>
            end case;
          end if;
        when ready =>
          pro_state_machine <= ready;
          
          if(m_axis_tready = '1') then
            readline(fileD, fileD_line);
            
            first_push := '0';
            
            case FILE_BASE is
              when 2 =>
                read(fileD_line, file_data);
              when 16=>
                hread(fileD_line, file_data);
              when others=>
            end case;
            
            m_axis_tdata  <= file_data;
            m_axis_tvalid <= '1';
            m_axis_tkeep  <= (others => '1');
            
            if(endfile(fileD)) then
              pro_state_machine <= done;
              m_axis_tlast <= '1';
            end if;
          end if;
        when done  =>
          pro_state_machine <= done;
          
          if(m_axis_tready = '1') then
            m_axis_tvalid <= '0';
            m_axis_tlast  <= '0';
            m_axis_tkeep <= (others => '0');
          end if;
      end case;
    end if;
  end process;
end read_file;

architecture const_data of axi_streaming_slave_stimulus is
begin
  producer : process(m_axis_aclk, arstn)
  begin
    if(arstn = '0') then
      --reset
      m_axis_tvalid <= '0';
      m_axis_tlast  <= '0';
      m_axis_tuser  <= (others => '0');
      m_axis_tdata  <= (others => '0');
      m_axis_tkeep  <= (others => '0');
      m_axis_tstrb  <= (others => '0');
    elsif(rising_edge(m_axis_aclk)) then
      m_axis_tvalid <= '1';
      m_axis_tlast  <= '0';

      m_axis_tstrb <= (others => '0');
      m_axis_tkeep <= (others => '1');
      m_axis_tdata <= std_logic_vector(to_unsigned(CONST_DATA, m_axis_tdata'length));
    end if;
  end process;
end const_data;

architecture repeat_counter of axi_streaming_slave_stimulus is
  type st_pro_state_machine is (idle, ready, done);
  signal pro_state_machine : st_pro_state_machine;
begin
  producer : process(m_axis_aclk, arstn)
    variable counter : integer := 0;
  begin
    if(arstn = '0') then
      --reset
      counter := 0;
      m_axis_tvalid <= '0';
      m_axis_tlast  <= '0';
      m_axis_tuser  <= (others => '0');
      m_axis_tdata  <= (others => '0');
      m_axis_tkeep  <= (others => '0');
      m_axis_tstrb  <= (others => '0');
      pro_state_machine <= idle;
    elsif(rising_edge(m_axis_aclk)) then
      case pro_state_machine is
        when idle =>
          pro_state_machine <= ready;

          counter := 0;

          m_axis_tvalid <= '1';
          m_axis_tlast  <= '0';

          m_axis_tstrb <= (others => '0');
          m_axis_tkeep <= (others => '1');
          m_axis_tdata <= std_logic_vector(to_unsigned(counter, m_axis_tdata'length));

          counter := counter + 1;
        when ready =>
          pro_state_machine <= ready;

          if(m_axis_tready = '1') then
            m_axis_tvalid <= '1';
            m_axis_tlast  <= '0';

            m_axis_tstrb <= (others => '0');
            m_axis_tkeep <= (others => '1');
            m_axis_tdata <= std_logic_vector(to_unsigned(counter, m_axis_tdata'length));

            counter := counter + 1;

            if(counter > COUNT_AMT-1) then
              m_axis_tlast <= '1';
              counter := 0;
            end if;
          end if;
        when others =>
          if(m_axis_tready = '1') then
            m_axis_tvalid <= '0';
            m_axis_tlast  <= '0';
            m_axis_tdata  <= (others => '0');
            m_axis_tkeep  <= (others => '0');
            m_axis_tstrb  <= (others => '0');
          end if;
      end case;
    end if;
  end process;
end repeat_counter;

architecture pause_repeat_counter of axi_streaming_slave_stimulus is
  type st_pro_state_machine is (idle, ready, done);
  signal pro_state_machine : st_pro_state_machine;
begin
  producer : process(m_axis_aclk, arstn)
    variable counter : integer := 0;
  begin
    if(arstn = '0') then
      --reset
      counter := 0;
      m_axis_tvalid <= '0';
      m_axis_tlast  <= '0';
      m_axis_tuser  <= (others => '0');
      m_axis_tdata  <= (others => '0');
      m_axis_tkeep  <= (others => '0');
      m_axis_tstrb  <= (others => '0');
      pro_state_machine <= idle;
    elsif(rising_edge(m_axis_aclk)) then
      case pro_state_machine is
        when idle =>
          pro_state_machine <= ready;

          counter := 0;

          m_axis_tvalid <= '1';
          m_axis_tlast  <= '0';

          m_axis_tstrb <= (others => '0');
          m_axis_tkeep <= (others => '1');
          m_axis_tdata <= std_logic_vector(to_unsigned(counter, m_axis_tdata'length));

          if(counter = COUNT_AMT-1) then
            m_axis_tlast <= '1';
            counter := 0;
            pro_state_machine <= done;
          else
            counter := counter + 1;
          end if;
        when ready =>
          pro_state_machine <= ready;

          if(m_axis_tready = '1') then
            m_axis_tvalid <= '1';
            m_axis_tlast  <= '0';

            m_axis_tstrb <= (others => '0');
            m_axis_tkeep <= (others => '1');
            m_axis_tdata <= std_logic_vector(to_unsigned(counter, m_axis_tdata'length));

            if(counter = COUNT_AMT-1) then
              m_axis_tlast <= '1';
              counter := 0;
              pro_state_machine <= done;
            end if;

            counter := counter + 1;
          end if;
        when done =>
          pro_state_machine <= done;

          if(m_axis_tready = '1') then
            m_axis_tvalid <= '0';
            m_axis_tlast  <= '0';
            m_axis_tdata  <= (others => '0');
            m_axis_tkeep  <= (others => '0');
            m_axis_tstrb  <= (others => '0');
          end if;

          if(counter = COUNT_AMT-1) then
            pro_state_machine <= idle;
          end if;

          counter := counter + 1;
      end case;
    end if;
  end process;
end pause_repeat_counter;

architecture pause_repeat_every_other_valid_counter of axi_streaming_slave_stimulus is
  type st_pro_state_machine is (idle, ready, skip, done);
  signal pro_state_machine : st_pro_state_machine;
begin
  producer : process(m_axis_aclk, arstn)
    variable counter : integer := 0;
  begin
    if(arstn = '0') then
      --reset
      counter := 0;
      m_axis_tvalid <= '0';
      m_axis_tlast  <= '0';
      m_axis_tuser  <= (others => '0');
      m_axis_tdata  <= (others => '0');
      m_axis_tkeep  <= (others => '0');
      m_axis_tstrb  <= (others => '0');
      pro_state_machine <= idle;
    elsif(rising_edge(m_axis_aclk)) then
      case pro_state_machine is
        when idle =>
          pro_state_machine <= skip;

          counter := 0;

          m_axis_tvalid <= '1';
          m_axis_tlast  <= '0';

          m_axis_tstrb <= (others => '0');
          m_axis_tkeep <= (others => '1');
          m_axis_tdata <= std_logic_vector(to_unsigned(counter, m_axis_tdata'length));

          if(counter = COUNT_AMT-1) then
            m_axis_tlast <= '1';
            counter := 0;
            pro_state_machine <= done;
          else
            counter := counter + 1;
          end if;
        when skip =>
          pro_state_machine <= skip;
            
          m_axis_tvalid <= '1';
          
          if(m_axis_tready = '1') then
            pro_state_machine <= ready;
            
            m_axis_tvalid <= '0';
          end if;
        when ready =>
          pro_state_machine <= ready;

          if(m_axis_tready = '1') then
            m_axis_tvalid <= '1';
            m_axis_tlast  <= '0';

            m_axis_tstrb <= (others => '0');
            m_axis_tkeep <= (others => '1');
            m_axis_tdata <= std_logic_vector(to_unsigned(counter, m_axis_tdata'length));

            pro_state_machine <= skip;
            
            if(counter = COUNT_AMT-1) then
              m_axis_tlast <= '1';
              counter := 0;
              pro_state_machine <= done;
            end if;

            counter := counter + 1;
          end if;
        when done =>
          pro_state_machine <= done;

          if(m_axis_tready = '1') then
            m_axis_tvalid <= '0';
            m_axis_tlast  <= '0';
            m_axis_tdata  <= (others => '0');
            m_axis_tkeep  <= (others => '0');
            m_axis_tstrb  <= (others => '0');
          end if;

          if(counter = COUNT_AMT-1) then
            pro_state_machine <= idle;
          end if;

          counter := counter + 1;
      end case;
    end if;
  end process;
end pause_repeat_every_other_valid_counter;

--! Axi streaming master stimulus component
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_textio.all;
use IEEE.math_real.all;
--std text io
use std.textio.all;

entity axi_streaming_master_stimulus is
  generic (
            --! slave bus size in bytes
            S_BUS_WIDTH : positive  := 8;
            --! User width in bits
            S_USER_WIDTH : positive := 1;
            --! File output name (TXT only)
            FILE_NAME   : string    := "output.txt";
            --! File input base in AND out
            FILE_BASE   : natural   := 2;
            --! Add a offset to create a hexdump styled output
            FILE_BASE_WITH_OFFSET : std_logic := '0';
            --! Randomize the ready signal to the unit under test.
            RND_READY   : std_logic := '0'
          );
  port    (
            arstn        : in std_logic;
            s_axis_aclk  : in std_logic;
            --! slave axi streaming interface
            s_axis_tdata : in std_logic_vector((8*S_BUS_WIDTH-1) downto 0);
            s_axis_tkeep : in std_logic_vector((S_BUS_WIDTH-1) downto 0);
            s_axis_tstrb : in std_logic_vector((S_BUS_WIDTH-1) downto 0);
            s_axis_tuser : in std_logic_vector(S_USER_WIDTH-1 downto 0);
            s_axis_tvalid: in std_logic;
            s_axis_tlast : in std_logic;
            s_axis_tready: out std_logic
          );
end axi_streaming_master_stimulus;

architecture write_file of axi_streaming_master_stimulus is
  file fileD : text open write_mode is FILE_NAME;
  
  type st_con_state_machine is (idle, ready);
  signal con_state_machine : st_con_state_machine;
  
  signal rand_ready : std_logic_vector(31 downto 0) := (others => '1');
begin

  rnd : if RND_READY = '1' generate
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
  
  consumer : process(s_axis_aclk, arstn)
    variable fileD_line : line;
  begin
    if(arstn = '0') then
      s_axis_tready <= '0';
      con_state_machine <= idle;
    elsif(rising_edge(s_axis_aclk)) then
      case con_state_machine is
        when idle =>
          con_state_machine <= idle;
          s_axis_tready <= '0';
          
          if(rand_ready(0) = '1' OR s_axis_tvalid = '1') then
            con_state_machine <= ready;
            s_axis_tready <= '1';
          end if;
        when ready=>
          con_state_machine <= ready;
          
          s_axis_tready <= rand_ready(0);
          
          if(s_axis_tvalid = '1') then
            case FILE_BASE is
              when 2 =>
                write(fileD_line, s_axis_tdata);
                writeline(fileD, fileD_line);
              when 16=>
                hwrite(fileD_line, s_axis_tdata);
                
                writeline(fileD, fileD_line);
              when others=>
            end case;
          end if;
          
          if(rand_ready(0) = '0') then
            con_state_machine <= idle;
          end if;
          
          if(s_axis_tlast = '1') then
            file_close(fileD);
            file_open(fileD, FILE_NAME, append_mode);
          end if;
      end case;
    end if;
  end process;
end write_file;

architecture hex_dump of axi_streaming_master_stimulus is
  file fileD : text open write_mode is FILE_NAME;
  
  type st_con_state_machine is (idle, ready);
  signal con_state_machine : st_con_state_machine;
  
  signal rand_ready : std_logic_vector(31 downto 0) := (others => '1');
begin

  rnd : if RND_READY = '1' generate
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
  
  consumer : process(s_axis_aclk, arstn)
    variable fileD_line : line;
    variable counter    : unsigned(31 downto 0);
  begin
    if(arstn = '0') then
      s_axis_tready <= '0';
      counter := (others => '0');
      con_state_machine <= idle;
    elsif(rising_edge(s_axis_aclk)) then
      case con_state_machine is
        when idle =>
          con_state_machine <= idle;
          s_axis_tready <= '0';
          
          if(rand_ready(0) = '1' OR s_axis_tvalid = '1') then
            con_state_machine <= ready;
            s_axis_tready <= '1';
          end if;
        when ready=>
          con_state_machine <= ready;
          
          s_axis_tready <= rand_ready(0);
          
          if(s_axis_tvalid = '1') then
            case FILE_BASE is
              when 2 =>
                hwrite(fileD_line, std_logic_vector(counter), left, counter'length/4 + 1);
                
                write(fileD_line, s_axis_tdata);
                writeline(fileD, fileD_line);
              when 16=>
                hwrite(fileD_line, std_logic_vector(counter), left, counter'length/4 + 1);
                
                for index in s_axis_tkeep'range loop
                  hwrite(fileD_line, s_axis_tdata(8*(index+1)-1 downto 8*index), left, 3);
                end loop;
                
                counter := counter + s_axis_tkeep'length;
                
                writeline(fileD, fileD_line);
              when others=>
            end case;
          end if;
          
          if(rand_ready(0) = '0') then
            con_state_machine <= idle;
          end if;
          
          if(s_axis_tlast = '1') then
            file_close(fileD);
            file_open(fileD, FILE_NAME, append_mode);
          end if;
      end case;
    end if;
  end process;
end hex_dump;
