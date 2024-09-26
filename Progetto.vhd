library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity input_memory is
    port(
        i_clk : in std_logic;
        i_start : in std_logic;
        i_w : in std_logic;
        i_state : in std_logic_vector(2 downto 0);
        o_mem_addr : out std_logic_vector(15 downto 0);
        o_channel : out std_logic_vector(1 downto 0)
    );
end input_memory;

architecture input_memory_arch of input_memory is
    signal r_mem_addr : std_logic_vector(15 downto 0) := "0000000000000000";
    
begin
    o_mem_addr <= r_mem_addr;
    get_input : process(i_clk)
    begin
        if i_clk'event AND i_clk='1' then
            case i_state is               
            when "000" =>
                if i_start='1' then
                    r_mem_addr <= "0000000000000000";
                    o_channel(1) <= i_w;
                end if;
            when "001" =>
                o_channel(0) <= i_w;
            when "010" =>
                if i_start='1' then
                    r_mem_addr <= r_mem_addr(14 downto 0) & i_w;
                end if; 
            when others => NULL;                         
            end case;            
        end if;
    end process;
    
end input_memory_arch;



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity state_register is
    port(
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_start : in std_logic;
        o_en : out std_logic :='0';
        o_state : out std_logic_vector(2 downto 0);
        o_done : out std_logic :='0'
    );
end state_register;

architecture state_register_arch of state_register is
    signal r_state : std_logic_vector(2 downto 0) := "000";
begin
    o_state <= r_state;
    change_state : process(i_rst, i_clk)
    begin
        if i_rst='1' then
            r_state <= "000";
            o_en <= '0';
            o_done <= '0';        
        elsif i_clk'event AND i_clk='1' then
            case r_state is               
            when "000" =>
                if i_start='1' then
                    r_state<="001";
                end if;
            when "001" =>
                if i_start='1' then
                    r_state<="010";
                end if;
            when "010" =>
                if i_start='0' then
                    o_en <= '1';
                    r_state <= "011";
                end if;
            when "011" =>
                r_state<="100";
            when "100" =>
                o_en <= '0';
                o_done <= '1';
                r_state <= "101";              
            when others =>
                o_done <= '0';
                r_state <= "000";                   
            end case;           
       end if;
    end process;
    
end state_register_arch;




library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity channels_registers is
    port(
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_mem_data : in std_logic_vector(7 downto 0);
        i_state : in std_logic_vector(2 downto 0);
        i_channel : in std_logic_vector (1 downto 0);
        i_done : in std_logic;
        o_z0 : out std_logic_vector(7 downto 0);
        o_z1 : out std_logic_vector(7 downto 0);
        o_z2 : out std_logic_vector(7 downto 0);
        o_z3 : out std_logic_vector(7 downto 0)
    );
end channels_registers;

architecture channels_registers_arch of channels_registers is
    signal mem_z0 : std_logic_vector(7 downto 0) :="00000000";
    signal mem_z1 : std_logic_vector(7 downto 0) :="00000000";
    signal mem_z2 : std_logic_vector(7 downto 0) :="00000000";
    signal mem_z3 : std_logic_vector(7 downto 0) :="00000000";    
    
begin
    o_z0 <= (i_done & i_done & i_done & i_done & i_done & i_done & i_done & i_done) AND mem_z0;
    o_z1 <= (i_done & i_done & i_done & i_done & i_done & i_done & i_done & i_done) AND mem_z1;
    o_z2 <= (i_done & i_done & i_done & i_done & i_done & i_done & i_done & i_done) AND mem_z2;
    o_z3 <= (i_done & i_done & i_done & i_done & i_done & i_done & i_done & i_done) AND mem_z3;  
          
    set_memory : process(i_rst, i_clk)
    begin
        if i_rst='1' then        
            mem_z0 <= "00000000";
            mem_z1 <= "00000000";
            mem_z2 <= "00000000";
            mem_z3 <= "00000000";     
        elsif i_clk'event AND i_clk='1' then
            if i_state="100" then
                case i_channel is
                    when "00" =>
                        mem_z0 <= i_mem_data;
                    when "01" =>
                        mem_z1 <= i_mem_data;
                    when "10" =>
                        mem_z2 <= i_mem_data;
                    when others =>
                        mem_z3 <= i_mem_data;
                end case;  
            end if;      
        end if;
    end process;
    
end channels_registers_arch;



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity project_reti_logiche is
    port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_start : in std_logic;
        i_w : in std_logic;
        o_z0 : out std_logic_vector(7 downto 0);
        o_z1 : out std_logic_vector(7 downto 0);
        o_z2 : out std_logic_vector(7 downto 0);
        o_z3 : out std_logic_vector(7 downto 0);
        o_done : out std_logic;
        o_mem_addr : out std_logic_vector(15 downto 0);
        i_mem_data : in std_logic_vector(7 downto 0);
        o_mem_we : out std_logic;
        o_mem_en : out std_logic
    );
    
end project_reti_logiche;

architecture project_reti_logiche_arch of project_reti_logiche is
    signal state : std_logic_vector (2 downto 0);
    signal channel : std_logic_vector(1 downto 0);
    signal done : std_logic;
    
    component input_memory is
        port(
            i_clk : in std_logic;
            i_start : in std_logic;
            i_w : in std_logic;
            i_state : in std_logic_vector(2 downto 0);
            o_mem_addr : out std_logic_vector(15 downto 0);
            o_channel : out std_logic_vector(1 downto 0)
        );
    end component;
    component state_register is
        port(
            i_clk : in std_logic;
            i_rst : in std_logic;
            i_start : in std_logic;
            o_en : out std_logic;
            o_state : out std_logic_vector(2 downto 0);
            o_done : out std_logic
        );
    end component;
    component channels_registers is
        port(
            i_clk : in std_logic;
            i_rst : in std_logic;
            i_mem_data : in std_logic_vector(7 downto 0);
            i_state : in std_logic_vector(2 downto 0);
            i_channel : in std_logic_vector (1 downto 0);
            i_done : in std_logic;
            o_z0 : out std_logic_vector(7 downto 0);
            o_z1 : out std_logic_vector(7 downto 0);
            o_z2 : out std_logic_vector(7 downto 0);
            o_z3 : out std_logic_vector(7 downto 0)
        );
    end component;

begin
    o_mem_we <= '0';
    o_done <= done;
    
    INPUT : input_memory port map (
        i_clk => i_clk,
        i_start => i_start,
        i_w => i_w,
        i_state => state,
        o_mem_addr => o_mem_addr,
        o_channel => channel
    );
    
    STATE_REG : state_register port map(
        i_clk => i_clk,
        i_rst => i_rst,
        i_start => i_start,
        o_en => o_mem_en,
        o_state => state,
        o_done => done
    );
    CHANNELS_REG : channels_registers port map(
        i_clk => i_clk,
        i_rst => i_rst,
        i_mem_data => i_mem_data,
        i_state => state,
        i_channel => channel,
        i_done => done,
        o_z0 => o_z0,
        o_z1 => o_z1,
        o_z2 => o_z2,
        o_z3 => o_z3
    );
    
    
end project_reti_logiche_arch;