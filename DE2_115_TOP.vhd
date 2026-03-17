--
-- DE2-115 top-level module (entity declaration)
--
-- William H. Robinson, Vanderbilt University University
--   william.h.robinson@vanderbilt.edu
--
-- Updated from the DE2 top-level module created by 
-- Stephen A. Edwards, Columbia University, sedwards@cs.columbia.edu
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DE2_115_TOP is
  generic (
    TICKS_PER_SECOND : natural := 50_000_000  -- default for 50 MHz CLOCK_50
  );
  port (
    -- Clocks
    
    CLOCK_50 	: in std_logic;                     -- 50 MHz
    CLOCK2_50 	: in std_logic;                     -- 50 MHz
    CLOCK3_50 	: in std_logic;                     -- 50 MHz
    SMA_CLKIN  : in std_logic;                     -- External Clock Input
    SMA_CLKOUT : out std_logic;                    -- External Clock Output

    -- Buttons and switches
    
    KEY : in std_logic_vector(3 downto 0);         -- Push buttons
    SW  : in std_logic_vector(17 downto 0);        -- DPDT switches

    -- LED displays

    HEX0 : out std_logic_vector(6 downto 0);       -- 7-segment display (active low)
    HEX1 : out std_logic_vector(6 downto 0);       -- 7-segment display (active low)
    HEX2 : out std_logic_vector(6 downto 0);       -- 7-segment display (active low)
    HEX3 : out std_logic_vector(6 downto 0);       -- 7-segment display (active low)
    HEX4 : out std_logic_vector(6 downto 0);       -- 7-segment display (active low)
    HEX5 : out std_logic_vector(6 downto 0);       -- 7-segment display (active low)
    HEX6 : out std_logic_vector(6 downto 0);       -- 7-segment display (active low)
    HEX7 : out std_logic_vector(6 downto 0);       -- 7-segment display (active low)
    LEDG : out std_logic_vector(8 downto 0);       -- Green LEDs (active high)
    LEDR : out std_logic_vector(17 downto 0);      -- Red LEDs (active high)

    -- RS-232 interface

    UART_CTS : out std_logic;                      -- UART Clear to Send   
    UART_RTS : in std_logic;                       -- UART Request to Send   
    UART_RXD : in std_logic;                       -- UART Receiver
    UART_TXD : out std_logic;                      -- UART Transmitter   

    -- 16 X 2 LCD Module
    
    LCD_BLON : out std_logic;      							-- Back Light ON/OFF
    LCD_EN   : out std_logic;      							-- Enable
    LCD_ON   : out std_logic;      							-- Power ON/OFF
    LCD_RS   : out std_logic;	   							-- Command/Data Select, 0 = Command, 1 = Data
    LCD_RW   : out std_logic; 	   						-- Read/Write Select, 0 = Write, 1 = Read
    LCD_DATA : inout std_logic_vector(7 downto 0); 	-- Data bus 8 bits

    -- PS/2 ports

    PS2_CLK : inout std_logic;     -- Clock
    PS2_DAT : inout std_logic;     -- Data

    PS2_CLK2 : inout std_logic;    -- Clock
    PS2_DAT2 : inout std_logic;    -- Data

    -- VGA output
    
    VGA_BLANK_N : out std_logic;            -- BLANK
    VGA_CLK 	 : out std_logic;            -- Clock
    VGA_HS 		 : out std_logic;            -- H_SYNC
    VGA_SYNC_N  : out std_logic;            -- SYNC
    VGA_VS 		 : out std_logic;            -- V_SYNC
    VGA_R 		 : out unsigned(7 downto 0); -- Red[9:0]
    VGA_G 		 : out unsigned(7 downto 0); -- Green[9:0]
    VGA_B 		 : out unsigned(7 downto 0); -- Blue[9:0]

    -- SRAM
    
    SRAM_ADDR : out unsigned(19 downto 0);         -- Address bus 20 Bits
    SRAM_DQ   : inout unsigned(15 downto 0);       -- Data bus 16 Bits
    SRAM_CE_N : out std_logic;                     -- Chip Enable
    SRAM_LB_N : out std_logic;                     -- Low-byte Data Mask 
    SRAM_OE_N : out std_logic;                     -- Output Enable
    SRAM_UB_N : out std_logic;                     -- High-byte Data Mask 
    SRAM_WE_N : out std_logic;                     -- Write Enable

    -- Audio CODEC
    
    AUD_ADCDAT 	: in std_logic;               -- ADC Data
    AUD_ADCLRCK 	: inout std_logic;            -- ADC LR Clock
    AUD_BCLK 		: inout std_logic;            -- Bit-Stream Clock
    AUD_DACDAT 	: out std_logic;              -- DAC Data
    AUD_DACLRCK 	: inout std_logic;            -- DAC LR Clock
    AUD_XCK 		: out std_logic               -- Chip Clock
    
    );
  
end DE2_115_TOP;
architecture rtl of DE2_115_TOP is

  ------------------------------------------------------------------
  -- Problem 1: Debounce (20ms @ 50MHz)
  ------------------------------------------------------------------

  constant DEBOUNCE_TICKS : natural := TICKS_PER_SECOND / 50;

  signal raw_pressed       : std_logic;
  signal sync1, sync2      : std_logic := '0';
  signal stable_level      : std_logic := '0';
  signal stable_level_prev : std_logic := '0';
  signal cnt               : natural range 0 to DEBOUNCE_TICKS := 0;
  signal press_pulse       : std_logic := '0';

  ------------------------------------------------------------------
  -- Problem 2: 8-stage shift register (7-seg patterns)
  ------------------------------------------------------------------

  signal stage0, stage1, stage2, stage3 : std_logic_vector(6 downto 0) := (others => '1');
  signal stage4, stage5, stage6, stage7 : std_logic_vector(6 downto 0) := (others => '1');

  ------------------------------------------------------------------
  -- Problem 3: HELLO scroll sequence with gap
  -- HEX vector is (6 downto 0) = g f e d c b a
  -- Active-low (0 = ON)
  ------------------------------------------------------------------

  constant BLANK : std_logic_vector(6 downto 0) := "1111111";

  constant SEG_H : std_logic_vector(6 downto 0) := "0001001";
  constant SEG_E : std_logic_vector(6 downto 0) := "0000110";
  constant SEG_L : std_logic_vector(6 downto 0) := "1000111";
  constant SEG_O : std_logic_vector(6 downto 0) := "1000000";

  type scroll_array is array (0 to 12) of std_logic_vector(6 downto 0);

  constant SCROLL : scroll_array := (
    SEG_H,
    SEG_E,
    SEG_L,
    SEG_L,
    SEG_O,
    BLANK,
    BLANK,
    BLANK,
    BLANK,
    BLANK,
    BLANK,
    BLANK,
    BLANK
  );

  signal scroll_index : integer range 0 to 12 := 0;

begin

  ------------------------------------------------------------------
  -- Convert active-low KEY(0) to pressed = 1
  ------------------------------------------------------------------
  raw_pressed <= not KEY(0);

  ------------------------------------------------------------------
  -- Main synchronous process
  ------------------------------------------------------------------
  process(CLOCK_50)
  begin
    if rising_edge(CLOCK_50) then

      --------------------------------------------------------------
      -- Synchronous reset (SW(0) active-low)
      --------------------------------------------------------------
      if SW(0) = '0' then

        -- Reset debounce
        sync1 <= '0';
        sync2 <= '0';
        stable_level <= '0';
        stable_level_prev <= '0';
        cnt <= 0;
        press_pulse <= '0';

        -- Reset shift register
        stage0 <= BLANK;
        stage1 <= BLANK;
        stage2 <= BLANK;
        stage3 <= BLANK;
        stage4 <= BLANK;
        stage5 <= BLANK;
        stage6 <= BLANK;
        stage7 <= BLANK;

        scroll_index <= 0;

      else

        ----------------------------------------------------------
        -- (1) Two-flop synchronizer
        ----------------------------------------------------------
        sync1 <= raw_pressed;
        sync2 <= sync1;

        ----------------------------------------------------------
        -- (2) Debounce logic
        ----------------------------------------------------------
        if sync2 = stable_level then
          cnt <= 0;
        else
          if cnt = DEBOUNCE_TICKS then
            stable_level <= sync2;
            cnt <= 0;
          else
            cnt <= cnt + 1;
          end if;
        end if;

        ----------------------------------------------------------
        -- (3) Single clock pulse on button press
        ----------------------------------------------------------
        press_pulse <= stable_level and (not stable_level_prev);
        stable_level_prev <= stable_level;

        ----------------------------------------------------------
        -- (4) Shift register + insert new character
        ----------------------------------------------------------
        if press_pulse = '1' then

          -- Shift left
          stage7 <= stage6;
          stage6 <= stage5;
          stage5 <= stage4;
          stage4 <= stage3;
          stage3 <= stage2;
          stage2 <= stage1;
          stage1 <= stage0;

          -- Insert next character
          stage0 <= SCROLL(scroll_index);

          -- Update scroll index
          if scroll_index = 12 then
            scroll_index <= 0;
          else
            scroll_index <= scroll_index + 1;
          end if;

        end if;

      end if;
    end if;
  end process;

  ------------------------------------------------------------------
  -- Connect shift register to HEX displays
  ------------------------------------------------------------------
  HEX0 <= stage0;
  HEX1 <= stage1;
  HEX2 <= stage2;
  HEX3 <= stage3;
  HEX4 <= stage4;
  HEX5 <= stage5;
  HEX6 <= stage6;
  HEX7 <= stage7;

end architecture;