library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.env.finish;

entity spi_master_tb is
end spi_master_tb;

architecture sim of spi_master_tb is

    signal clk     : STD_LOGIC := '0';
    signal reset   : STD_LOGIC := '1';
    signal start   : STD_LOGIC := '0';

    signal tx_data : STD_LOGIC_VECTOR(7 downto 0) := x"A5";
    signal miso    : STD_LOGIC := '0';
    signal mosi    : STD_LOGIC;
    signal sclk    : STD_LOGIC;
    signal cs_n    : STD_LOGIC;
    signal rx_data : STD_LOGIC_VECTOR(7 downto 0);
    signal done    : STD_LOGIC;

    constant RX_BYTE : STD_LOGIC_VECTOR(7 downto 0) := x"3C";

begin

    clk <= not clk after 10 ns;

    DUT : entity work.spi_master
        port map (
            clk     => clk,
            reset   => reset,
            start   => start,
            tx_data => tx_data,
            miso    => miso,
            mosi    => mosi,
            sclk    => sclk,
            cs_n    => cs_n,
            rx_data => rx_data,
            done    => done
        );

    stimulus : process
    begin
        reset <= '1';
        wait for 100 ns;

        wait until falling_edge(clk);
        reset <= '0';

        wait until falling_edge(clk);
        start <= '1';

        wait until falling_edge(clk);
        start <= '0';

        wait until done = '1' for 20 us;

        assert done = '1'
            report "FAIL: SPI transfer timed out"
            severity failure;

        wait for 100 ns;

        assert rx_data = RX_BYTE
            report "FAIL: SPI receive mismatch"
            severity failure;

        assert cs_n = '1'
            report "FAIL: CS did not return high"
            severity failure;

        report "RX received decimal = " &
            integer'image(to_integer(unsigned(rx_data)))
            severity note;

        report "PASS: SPI receive verified"
            severity note;

        report "PASS: All SPI Tests Completed Successfully!"
            severity note;

        finish;
    end process;

    slave_model : process
    begin
        miso <= '0';

        wait until falling_edge(cs_n);

        for i in 7 downto 0 loop
            miso <= RX_BYTE(i);
            wait until rising_edge(sclk);
            wait until falling_edge(sclk);
        end loop;

        wait until cs_n = '1';
        wait;
    end process;

    mosi_checker : process
    begin
        wait until falling_edge(cs_n);

        for i in 7 downto 0 loop
            wait until rising_edge(sclk);
            wait for 1 ns;

            assert mosi = tx_data(7 - i)
                report "FAIL: MOSI bit mismatch"
                severity failure;
        end loop;

        report "PASS: All MOSI bits verified"
            severity note;

        wait until cs_n = '1';
        wait;
    end process;

end architecture sim;
