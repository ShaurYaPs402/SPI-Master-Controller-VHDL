library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity spi_master is
    Port (
        clk      : in  STD_LOGIC;
        reset    : in  STD_LOGIC;
        start    : in  STD_LOGIC;
        tx_data  : in  STD_LOGIC_VECTOR(7 downto 0);
        miso     : in  STD_LOGIC;
        mosi     : out STD_LOGIC;
        sclk     : out STD_LOGIC;
        cs_n     : out STD_LOGIC;
        rx_data  : out STD_LOGIC_VECTOR(7 downto 0);
        done     : out STD_LOGIC
    );
end spi_master;

architecture Behavioral of spi_master is

    type state_type is (IDLE, LOAD, TRANSFER, FINISH);

    signal current_state : state_type := IDLE;

    signal shift_reg : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal rx_reg    : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');

    signal bit_count : integer range 0 to 7 := 0;
    signal clk_count : integer range 0 to 49 := 0;

    signal sclk_reg : STD_LOGIC := '0';

begin

    process(clk, reset)
    begin
        if reset = '1' then
            current_state <= IDLE;
            shift_reg     <= (others => '0');
            rx_reg        <= (others => '0');
            bit_count     <= 0;
            clk_count     <= 0;
            sclk_reg      <= '0';

        elsif rising_edge(clk) then

            case current_state is

                when IDLE =>
                    sclk_reg  <= '0';
                    clk_count <= 0;
                    bit_count <= 0;

                    if start = '1' then
                        current_state <= LOAD;
                    end if;

                when LOAD =>
                    shift_reg <= tx_data;
                    rx_reg    <= (others => '0');
                    bit_count <= 0;
                    clk_count <= 0;
                    sclk_reg  <= '0';

                    current_state <= TRANSFER;

                when TRANSFER =>
                    if clk_count = 49 then
                        clk_count <= 0;

                        if sclk_reg = '0' then
                            sclk_reg <= '1';
                            rx_reg   <= rx_reg(6 downto 0) & miso;

                        else
                            sclk_reg <= '0';

                            if bit_count < 7 then
                                shift_reg <= shift_reg(6 downto 0) & '0';
                                bit_count <= bit_count + 1;
                            else
                                current_state <= FINISH;
                            end if;
                        end if;

                    else
                        clk_count <= clk_count + 1;
                    end if;

                when FINISH =>
                    sclk_reg      <= '0';
                    clk_count     <= 0;
                    current_state <= IDLE;

            end case;
        end if;
    end process;

    sclk    <= sclk_reg;
    mosi    <= shift_reg(7);
    rx_data <= rx_reg;

    cs_n <= '0' when current_state = TRANSFER else '1';
    done <= '1' when current_state = FINISH else '0';

end architecture Behavioral;
