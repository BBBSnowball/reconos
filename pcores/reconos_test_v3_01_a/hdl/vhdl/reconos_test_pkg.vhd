--                                                        ____  _____
--                            ________  _________  ____  / __ \/ ___/
--                           / ___/ _ \/ ___/ __ \/ __ \/ / / /\__ \
--                          / /  /  __/ /__/ /_/ / / / / /_/ /___/ /
--                         /_/   \___/\___/\____/_/ /_/\____//____/
-- 
-- ======================================================================
--
--   title:        VHDL Package - ReconOS
--
--   project:      ReconOS
--   author:       Enno Lübbers, University of Paderborn
--                 Andreas Agne, University of Paderborn
--                 Christoph Rüthing, University of Paderborn
--                 Benjamin Koch, University of Paderborn
--   description:  The 'other' end of the ReconOS API for testing cores
--                 in HDL simulation.
--
-- ======================================================================


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;

library reconos_v3_01_a;
use reconos_v3_01_a.reconos_pkg.all;

library reconos_test_v3_01_a;
use reconos_test_v3_01_a.test_helpers.all;

package reconos_test_pkg is
	-- all signals that are inputs for the hardware core are Xputs for us and v.v.
	alias i_fifo_test_t is o_fifo_t;
	alias o_fifo_test_t is i_fifo_t;
	alias i_ram_test_t is o_ram_t;
	alias o_ram_test_t is i_ram_t;

	-- alias to alias causes 'Internal Compiler Error in file ../src/VhdlDecl.cpp at line 1843',
	-- so we refer to [io]_fifo_t instead of the appropriate alias.
	alias i_osif_test_t is o_fifo_t;  -- i_fifo_test_t
	alias o_osif_test_t is i_fifo_t;  -- o_fifo_test_t
	alias i_memif_test_t is o_fifo_t; -- i_fifo_test_t
	alias o_memif_test_t is i_fifo_t; -- o_fifo_test_t


	subtype fifo_word is std_logic_vector(C_FIFO_WIDTH - 1 downto 0);
	subtype osif_word is std_logic_vector(C_OSIF_WIDTH - 1 downto 0);

	-- Default timeout for expect_* procedures
	constant DEFAULT_TIMEOUT : time := 1000us;


	type test_memory_t is array (natural range <>) of std_logic_vector(31 downto 0);

	-- setup functions

	-- ONLY FOR INTERNAL USE
	-- Assigns signals to the FIFO record. This function must be called
	-- asynchronously in the main entity including the OS-FSM.
	--
	--   i_fifo_test - i_fifo_test_t record
	--   o_fifo_test - o_fifo_test_t record
	--   s_data      - data signal of slave FIFO
	--   s_fill      - fill signal of slave FIFO
	--   s_empty     - empty signal of slave FIFO
	--   m_rem       - remaining signal of master FIFO
	--   m_full      - full signal of master FIFO
	--   s_re        - read signal of slave FIFO
	--   m_data      - data signal of master FIFO
	--   m_we        - write signal of master FIFO
	--
	procedure fifo_setup_test (
		signal i_fifo_test : out i_fifo_test_t;
		signal o_fifo_test : in  o_fifo_test_t;
		signal s_data      : out std_logic_vector(C_FIFO_WIDTH - 1 downto 0);
		signal s_fill      : out std_logic_vector(15 downto 0);
		signal s_empty     : out std_logic;
		signal m_rem       : out std_logic_vector(15 downto 0);
		signal m_full      : out std_logic;
		signal s_re        : in  std_logic;
		signal m_data      : in  std_logic_vector(C_FIFO_WIDTH - 1 downto 0);
		signal m_we        : in  std_logic
	);
	
	-- ONLY FOR INTERNAL USE
	-- Resets the FIFO signals to a default state.
	--
	--   o_fifo_test - o_fifo_test_t record
	--
	procedure fifo_reset_test (
		signal o_fifo_test  : out o_fifo_test_t
	);


	-- Assigns signals to the OSIF record. This function must be called
	-- asynchronously in the main entity including the OS-FSM.
	--
	--   i_osif_test - i_osif_test_t record
	--   o_osif_test - o_osif_test_t_record
	--   sw2hw_data  - data signal of OSIF      - OSIF_FIFO_Sw2Hw_Data
	--   sw2hw_fill  - fill signal of OSIF      - OSIF_FIFO_Sw2Hw_Fill
	--   sw2hw_empty - empty signal of OSIF     - OSIF_FIFO_Sw2Hw_Empty
	--   hw2sw_rem   - remaining signal of OSIF - OSIF_FIFO_Hw2Sw_Rem
	--   hw2sw_full  - full signal of OSIF      - OSIF_FIFO_Hw2Sw_Full
	--   sw2hw_re    - read signal of OSIF      - OSIF_FIFO_Sw2Hw_RE
	--   hw2sw_data  - data signal of OSIF      - OSIF_FIFO_Hw2Sw_Data
	--   hw2sw_we    - write signal of OSIF     - OSIF_FIFO_Hw2Sw_WE
	--
	procedure osif_setup_test (
		signal i_osif_test  : out i_osif_test_t;
		signal o_osif_test  : in  o_osif_test_t;
		signal sw2hw_data   : out std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
		signal sw2hw_fill   : out std_logic_vector(15 downto 0);
		signal sw2hw_empty  : out std_logic;
		signal hw2sw_rem    : out std_logic_vector(15 downto 0);
		signal hw2sw_full   : out std_logic;
		signal sw2hw_re     : in  std_logic;
		signal hw2sw_data   : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
		signal hw2sw_we     : in  std_logic
	);
	
	-- Resets the OSIF signals to a default state. This function should be called
	-- on reset of the OS-FSM.
	--
	--   o_osif_test - o_osif_test_t record
	--
	procedure osif_reset_test (
		signal o_osif_test  : out o_osif_test_t
	);


	-- Assigns signals to the MEMIF record. This function must be called
	-- asynchronously in the main entity including the OS-FSM.
	--
	--   i_memif_test  - i_memif_test_t record
	--   o_memif_test  - o_memif_test_t record
	--   mem2hwt_data  - data signal of MEMIF      - MEMIF_FIFO_Mem2Hwt_Data
	--   mem2hwt_fill  - fill signal of MEMIF      - MEMIF_FIFO_Mem2Hwt_Fill
	--   mem2hwt_empty - empty signal of MEMIF     - MEMIF_FIFO_Mem2Hwt_Empty
	--   hwt2mem_rem   - remaining signal of MEMIF - MEMIF_FIFO_Hwt2Mem_Rem
	--   hwt2mem_full  - full signal of MEMIF      - MEMIF_FIFO_Hwt2Mem_Full
	--   mem2hwt_re    - read signal of MEMIF      - MEMIF_FIFO_Mem2Hwt_RE
	--   hwt2mem_data  - data signal of MEMIF      - MEMIF_FIFO_Hwt2Mem_Data
	--   hwt2mem_we    - write signal of MEMIF     - MEMIF_FIFO_Hwt2Mem_WE
	--
	procedure memif_setup_test (
		signal i_memif_test   : out i_memif_test_t;
		signal o_memif_test   : in  o_memif_test_t;
		signal mem2hwt_data   : out std_logic_vector(C_MEMIF_WIDTH - 1 downto 0);
		signal mem2hwt_fill   : out std_logic_vector(15 downto 0);
		signal mem2hwt_empty  : out std_logic;
		signal hwt2mem_rem    : out std_logic_vector(15 downto 0);
		signal hwt2mem_full   : out std_logic;
		signal mem2hwt_re     : in  std_logic;
		signal hwt2mem_data   : in  std_logic_vector(C_MEMIF_WIDTH - 1 downto 0);
		signal hwt2mem_we     : in  std_logic
	);
	
	-- Resets the MEMIF signals to a default state. This function should be called
	-- on reset of the OS-FSM.
	--
	--   o_memif_test - o_memif_test_t record
	--
	procedure memif_reset_test (
		signal o_memif_test  : out o_memif_test_t
	);

	-- ONLY FOR INTERNAL USE
	--
	-- Waits for the slave to read a single word.
	--
	--   i_fifo    - i_fifo_t record
	--   o_fifo    - o_fifo_t record
	--   result    - the word read from the FIFO
	--   next_step - the new value of o_fifo.step after the word was read
	--   continue  - boolean value, indicating if the next clock cycle another
	--               read will be performed
	--
	procedure expect_fifo_pull_word (
		signal clk          : in  std_logic;
		signal i_fifo_test  : in  i_fifo_test_t;
		signal o_fifo_test  : out o_fifo_test_t;
		constant data       : in  std_logic_vector(C_FIFO_WIDTH - 1 downto 0);
		constant timeout    : in  time := DEFAULT_TIMEOUT
	);

	-- ONLY FOR INTERNAL USE
	--
	-- Waits for the slave to write a single word.
	--
	--   i_fifo    - i_fifo_t record
	--   o_fifo    - o_fifo_t record
	--   data      - the word that should be written into the FIFO
	--   next_step - the new value of o_fifo.step after the word was written
	--
	procedure expect_fifo_push_word (
		signal clk          : in  std_logic;
		signal i_fifo_test  : in  i_fifo_test_t;
		signal o_fifo_test  : out o_fifo_test_t;
		variable data       : out std_logic_vector(C_FIFO_WIDTH - 1 downto 0);
		constant timeout    : in  time := DEFAULT_TIMEOUT
	);

	-- ONLY FOR INTERNAL USE
	--
	-- Expects that the slave reads multiple words.
	--
	procedure expect_fifo_pull (
		signal   clk      : in  std_logic;
		signal   i_fifo   : in  i_fifo_test_t;
		signal   o_fifo   : out o_fifo_test_t;
		constant ram      : in  test_memory_t;
		constant addr     : in  natural;
		constant count    : in  natural;
		constant timeout  : in  time := DEFAULT_TIMEOUT
	);
	
	-- ONLY FOR INTERNAL USE
	--
	-- Expects that the slave writes multiple words.
	--
	procedure expect_fifo_push (
		signal   clk      : in    std_logic;
		signal   i_fifo   : in    i_fifo_test_t;
		signal   o_fifo   : out   o_fifo_test_t;
		variable ram      : inout test_memory_t;
		constant addr     : in    natural;
		constant count    : in    natural; --TODO subtype of natural
		constant timeout  : in    time := DEFAULT_TIMEOUT
	);
	
	
	-- functions to access osif directly

	-- Expect the slave to read a single word from the OSIF.
	--
	--   i_osif - i_osif_test_t record
	--   o_osif - o_osif_test_t record
	--   result - word read from the OSIF
	--   done   - indicates when read finished
	--
	procedure expect_osif_read (
		signal clk        : in std_logic;
		signal i_osif     : in  i_osif_test_t;
		signal o_osif     : out o_osif_test_t;
		constant data     : in std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
		constant timeout  : in time := DEFAULT_TIMEOUT
	);
	
	-- Expect the slave to write a single word into the OSIF
	--
	--   i_osif - i_osif_test_t record
	--   o_osif - o_osif_test_t record
	--   data   - word to write int the OSIF
	--   done   - indicates when write finished
	-- 
	procedure expect_osif_write (
		signal clk       : in  std_logic;
		signal i_osif    : in  i_osif_test_t;
		signal o_osif    : out o_osif_test_t;
		variable data    : out std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
		constant timeout : in  time := DEFAULT_TIMEOUT
	);


	-- generic osif functions

	-- ONLY FOR INTERNAL USE
	--
	-- Expect that the slave issues a system call with no arguments and a single result.
	--
	--   i_osif  - i_osif_t record
	--   o_osif  - o_osif_t record
	--   call_id - id of the system call
	--   result  - result of the system call
	--   done    - indicates when system call finished
	--
	procedure expect_osif_call_0 (
		signal clk                 : in  std_logic;
		signal i_osif              : in  i_osif_test_t;
		signal o_osif              : out o_osif_test_t;
		constant expected_call_id  : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
		constant result            : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
		constant timeout           : in  time := DEFAULT_TIMEOUT
	);

	-- ONLY FOR INTERNAL USE
	--
	-- Expect that the slave issues a system call with one argument and a single result.
	--
	--   i_osif  - i_osif_t record
	--   o_osif  - o_osif_t record
	--   call_id - id of the system call
	--   arg0    - argument of the system call
	--   result  - result of the system call
	--   done    - indicates when system call finished
	--
	procedure expect_osif_call_1 (
		signal clk                 : in  std_logic;
		signal i_osif              : in  i_osif_test_t;
		signal o_osif              : out o_osif_test_t;
		constant expected_call_id  : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
		constant expected_arg0     : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
		constant result            : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
		constant timeout           : in  time := DEFAULT_TIMEOUT
	);

	-- ONLY FOR INTERNAL USE
	--
	-- Expect that the slave issues a system call with one arguments and to results.
	--
	--   i_osif  - i_osif_t record
	--   o_osif  - o_osif_t record
	--   call_id - id of the system call
	--   arg0    - argument of the system call
	--   result1 - first result of the system call
	--   result2 - second result of the system call
	--   done    - indicates when system call finished
	--
	procedure expect_osif_call_1_2 (
		signal clk                 : in  std_logic;
		signal i_osif              : in  i_osif_test_t;
		signal o_osif              : out o_osif_test_t;
		constant expected_call_id  : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
		constant expected_arg0     : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
		constant result1           : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
		constant result2           : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
		constant timeout           : in  time := DEFAULT_TIMEOUT
	);

	-- ONLY FOR INTERNAL USE
	--
	-- Expect that the slave issues a system call with two arguments and a single result.
	--
	--   i_osif  - i_osif_t record
	--   o_osif  - o_osif_t record
	--   call_id - id of the system call
	--   arg0    - first argument of the system call
	--   arg1    - second argument of the system call
	--   result  - result of the system call
	--   done    - indicates when system call finished
	--
	procedure expect_osif_call_2 (
		signal clk                 : in  std_logic;
		signal i_osif              : in  i_osif_test_t;
		signal o_osif              : out o_osif_test_t;
		constant expected_call_id  : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
		constant expected_arg0     : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
		constant expected_arg1     : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
		constant result            : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
		constant timeout           : in  time := DEFAULT_TIMEOUT
	);


	-- osif functions
--
--	-- Yields the hardware thread slots. This causes the scheduler to be called
--	-- and might result in an preemtion of the hardware thread. This method alone
--	-- does not issue any call but only sets the yield bit for a regular system call.
--	--
--	--   i_osif - i_osif_t record
--	--   o_osif - o_osif_t record
--	--
--	procedure osif_set_yield (
--		signal i_osif  : in  i_osif_t;
--		signal o_osif  : out o_osif_t
--	);

	function ignore_yield(
		constant call_id : osif_word
	) return osif_word;


	-- Posts the semaphore specified by handle.
	--
	--   i_osif - i_osif_t record
	--   o_osif - o_osif_t record
	--   handle - indeout representing the resource in the resource array
	--   result - result of the osif call
	--   done   - indicates when call finished
	--
	procedure expect_osif_sem_post (
		signal   clk     : in  std_logic;
		signal   i_osif  : in  i_osif_test_t;
		signal   o_osif  : out o_osif_test_t;
		constant handle  : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
		constant result  : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0) := (others => '0');
		constant timeout : in  time := DEFAULT_TIMEOUT
	);

	-- Waits for the semaphore specified by handle.
	--
	--   i_osif - i_osif_t record
	--   o_osif - o_osif_t record
	--   handle - indeout representing the resource in the resource array
	--   result - result of the osif call
	--   done   - indicates when call finished
	--
	procedure expect_osif_sem_wait (
		signal   clk     : in  std_logic;
		signal   i_osif  : in  i_osif_test_t;
		signal   o_osif  : out o_osif_test_t;
		constant handle  : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
		constant result  : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0) := (others => '0');
		constant timeout : in  time := DEFAULT_TIMEOUT
	);
	
--	-- Locks the muteout specified by handle.
--	--
--	--   i_osif - i_osif_t record
--	--   o_osif - o_osif_t record
--	--   handle - indeout representing the resource in the resource array
--	--   result - result of the osif call
--	--   done   - indicates when call finished
--	--
--	procedure osif_mutex_lock (
--		signal i_osif  : in  i_osif_t;
--		signal o_osif  : out o_osif_t;
--		handle         : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
--		signal result  : out std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
--		variable done  : out boolean
--	);
--	
--	-- Unlocks the muteout specified by handle.
--	--
--	--   i_osif - i_osif_t record
--	--   o_osif - o_osif_t record
--	--   handle - indeout representing the resource in the resource array
--	--   result - result of the osif call
--	--   done   - indicates when call finished
--	--
--	procedure osif_mutex_unlock (
--		signal i_osif  : in  i_osif_t;
--		signal o_osif  : out o_osif_t;
--		handle         : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
--		signal result  : out std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
--		variable done  : out boolean
--	);
--	
--	-- Tries to lock the muteout specified by handle and returns if successful or not.
--	--
--	--   i_osif - i_osif_t record
--	--   o_osif - o_osif_t record
--	--   handle - indeout representing the resource in the resource array
--	--   result - result of the osif call
--	--   done   - indicates when call finished
--	--
--	procedure osif_mutex_trylock (
--		signal i_osif  : in  i_osif_t;
--		signal o_osif  : out o_osif_t;
--		handle         : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
--		signal result  : out std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
--		variable done  : out boolean
--	);
--	
--	-- Waits for the condition variable specified by handle.
--	--
--	--   i_osif - i_osif_t record
--	--   o_osif - o_osif_t record
--	--   handle - indeout representing the resource in the resource array
--	--   result - result of the osif call
--	--   done   - indicates when call finished
--	--
--	procedure osif_cond_wait (
--		signal i_osif  : in  i_osif_t;
--		signal o_osif  : out o_osif_t;
--		cond_handle    : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
--		mutex_handle   : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
--		signal result  : out std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
--		variable done  : out boolean
--	);
--	
--	-- Signals a single thread waiting on the condition variable specified by handle.
--	--
--	--   i_osif - i_osif_t record
--	--   o_osif - o_osif_t record
--	--   handle - indeout representing the resource in the resource array
--	--   result - result of the osif call
--	--   done   - indicates when call finished
--	--
--	procedure osif_cond_signal (
--		signal i_osif  : in  i_osif_t;
--		signal o_osif  : out o_osif_t;
--		handle         : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
--		signal result  : out std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
--		variable done  : out boolean
--	);
--	
--	-- Signals all threads waiting on the condition variable specified by handle.
--	--
--	--   i_osif - i_osif_t record
--	--   o_osif - o_osif_t record
--	--   handle - indeout representing the resource in the resource array
--	--   result - result of the osif call
--	--   done   - indicates when call finished
--	--
--	procedure osif_cond_broadcast (
--		signal i_osif  : in  i_osif_t;
--		signal o_osif  : out o_osif_t;
--		handle         : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
--		signal result  : out std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
--		variable done  : out boolean
--	);
--	
	-- Expect that the slave puts a single word into the mboout specified by handle.
	--
	procedure expect_osif_mbox_put (
		signal clk       : in  std_logic;
		signal i_osif    : in  i_osif_test_t;
		signal o_osif    : out o_osif_test_t;
		constant handle  : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
		constant word    : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
		constant result  : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0) := (others => '0');
		constant timeout : in  time := DEFAULT_TIMEOUT
	);
	
	-- Expect that the slave reads a single word from the mboout specified by handle.
	--
	procedure expect_osif_mbox_get (
		signal clk       : in  std_logic;
		signal i_osif    : in  i_osif_test_t;
		signal o_osif    : out o_osif_test_t;
		constant handle  : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
		constant result  : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
		constant timeout : in  time := DEFAULT_TIMEOUT
	);
--	
--	-- Tries to put a single word into the mboout specified by handle but does not
--	-- blocks until the mboout gets populated.
--	--
--	--   i_osif - i_osif_t record
--	--   o_osif - o_osif_t record
--	--   handle - indeout representing the resource in the resource array
--	--   word   - word to write into the mbox
--	--   result - indicates if word was written into the mbox
--	--   done   - indicates when call finished
--	--
--	procedure osif_mbox_tryput (
--		signal i_osif  : in  i_osif_t;
--		signal o_osif  : out o_osif_t;
--		handle         : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
--		word           : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
--		signal result  : out std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
--		variable done  : out boolean
--	);
--	
--	-- Tries to read a single word from the mboout specified by handle but does not
--	-- blocks until the mboout gets free.
--	--
--	--   i_osif  - i_osif_t record
--	--   o_osif  - o_osif_t record
--	--   handle  - indeout representing the resource in the resource array
--	--   result1 - word read from the mbox
--	--   result2 - indicates if a word was read from the mbox
--	--   done    - indicates when call finished
--	--
--	procedure osif_mbox_tryget (
--		signal i_osif  : in  i_osif_t;
--		signal o_osif  : out o_osif_t;
--		handle         : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
--		signal result1 : out std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
--		signal result2 : out std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
--		variable done  : out boolean
--	);
--	
--	-- NOT IMPLEMENTED YET
--	procedure osif_rq_receive (
--		signal i_osif  : in  i_osif_t;
--		signal o_osif  : out o_osif_t;
--		signal i_ram   : in  i_ram_t;
--		signal o_ram   : out o_ram_t;
--		handle         : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
--		size           : in  std_logic_vector(31 downto 0);
--		addr           : in  std_logic_vector(31 downto 0);
--		signal result  : out std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
--		variable done  : out boolean
--	);
--	
--	-- NOT IMPLEMENTED YET
--	procedure osif_rq_send (
--		signal i_osif  : in  i_osif_t;
--		signal o_osif  : out o_osif_t;
--		signal i_ram   : in  i_ram_t;
--		signal o_ram   : out o_ram_t;
--		handle         : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
--		size           : in  std_logic_vector(31 downto 0);
--		addr           : in  std_logic_vector(31 downto 0);
--		signal result  : out std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
--		variable done  : out boolean
--	);
--	
--	-- Gets the pointer to the initialization data of the hardware thread
--	-- specified by reconos_hwt_setinitdata.
--	--
--	--   i_osif - i_osif_t record
--	--   o_osif - o_osif_t record
--	--   result - the pointer to the initialization data
--	--   done   - indicated when call finished
--	--
--	procedure osif_get_init_data (
--		signal i_osif  : in  i_osif_t;
--		signal o_osif  : out o_osif_t;
--		signal result  : out std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
--		variable done  : out boolean
--	);
	
	-- Terminates the current hardware thread and the delegate in software.
	--
	procedure expect_osif_thread_exit (
		signal   clk     : in  std_logic;
		signal   i_osif  : in  i_osif_test_t;
		signal   o_osif  : out o_osif_test_t;
		constant timeout : in  time := DEFAULT_TIMEOUT
	);


	-- memif functions

	-- Lets the slave continue its work, if it is waiting in memif_flush.
	--
	--   clk      - clock
	--   i_memif  - i_memif_test_t record
	--   o_memif  - o_memif_test_t record
	--   timeout  - timeout for fifo operations
	--
	procedure acknowledge_memif_flush (
		signal   clk     : in  std_logic;
		signal   i_memif : in  i_memif_test_t;
		signal   o_memif : out o_memif_test_t;
		constant timeout : in  time := DEFAULT_TIMEOUT
	);

	-- Expect that the slave writes a single word into the main memory.
	--
	--   clk      - clock
	--   i_memif  - i_memif_test_t record
	--   o_memif  - o_memif_test_t record
	--   addr    - address of the main memory to write
	--   data    - word to write into the main memory
	--   timeout  - timeout for fifo operations
	--
	procedure expect_memif_write_word (
		signal   clk     : in  std_logic;
		signal   i_memif : in  i_memif_test_t;
		signal   o_memif : out o_memif_test_t;
		constant addr    : in  std_logic_vector(31 downto 0);
		variable data    : out  std_logic_vector(31 downto 0);
		constant timeout : in  time := DEFAULT_TIMEOUT
	);
	
	-- Expect that the slave reads a single word from the main memory.
	--
	--   clk      - clock
	--   i_memif  - i_memif_test_t record
	--   o_memif  - o_memif_test_t record
	--   addr    - address of the main memory to read from
	--   data    - word read from the main memory
	--   timeout  - timeout for fifo operations
	--
	procedure expect_memif_read_word (
		signal   clk     : in  std_logic;
		signal   i_memif : in  i_memif_test_t;
		signal   o_memif : out o_memif_test_t;
		constant addr    : in  std_logic_vector(31 downto 0);
		constant data    : in  std_logic_vector(31 downto 0);
		constant timeout : in  time := DEFAULT_TIMEOUT
	);

	-- Expect that the slave writes several words from the local ram into the main memory.
	--
	--   clk      - clock
	--   i_memif  - i_memif_test_t record
	--   o_memif  - o_memif_test_t record
	--   dst_addr - start address to write into the main memory
	--   len      - number of writes to transmit
	--   ram      - data to read
	--   ram_addr - start address in ram
	--   timeout  - timeout for fifo operations
	--
	procedure expect_memif_write (
		signal   clk      : in    std_logic;
		signal   i_memif  : in    i_memif_test_t;
		signal   o_memif  : out   o_memif_test_t;
		constant dst_addr : in    natural;
		constant len      : in    natural;
		variable ram      : inout test_memory_t;
		constant ram_addr : in    natural := 0;
		constant timeout  : in    time := DEFAULT_TIMEOUT
	);
	
	-- Expect that the slave writes several words from the local ram into the main memory.
	--
	--   clk      - clock
	--   i_memif  - i_memif_test_t record
	--   o_memif  - o_memif_test_t record
	--   src_addr - start address to read from the main memory
	--   len      - number of writes to transmit
	--   ram      - data to read
	--   ram_addr - start address in ram
	--   timeout  - timeout for fifo operations
	--
	procedure expect_memif_read (
		signal   clk      : in  std_logic;
		signal   i_memif  : in  i_memif_test_t;
		signal   o_memif  : out o_memif_test_t;
		constant src_addr : in  natural;
		constant len      : in  natural;
		constant ram      : in  test_memory_t;
		constant ram_addr : in  natural := 0;
		constant timeout  : in  time := DEFAULT_TIMEOUT
	);

end package reconos_test_pkg;

package body reconos_test_pkg is

	procedure fifo_setup_test (
		signal i_fifo_test : out i_fifo_test_t;
		signal o_fifo_test : in  o_fifo_test_t;
		signal s_data      : out std_logic_vector(C_FIFO_WIDTH - 1 downto 0);
		signal s_fill      : out std_logic_vector(15 downto 0);
		signal s_empty     : out std_logic;
		signal m_rem       : out std_logic_vector(15 downto 0);
		signal m_full      : out std_logic;
		signal s_re        : in  std_logic;
		signal m_data      : in  std_logic_vector(C_FIFO_WIDTH - 1 downto 0);
		signal m_we        : in  std_logic
	) is begin
		i_fifo_test.step <= o_fifo_test.step;
		
		s_data  <= o_fifo_test.s_data;
		s_fill  <= o_fifo_test.s_fill;
		s_empty <= o_fifo_test.s_empty;
		m_rem   <= o_fifo_test.m_rem;
		m_full  <= o_fifo_test.m_full;
		
		i_fifo_test.s_re    <= s_re;
		i_fifo_test.m_data  <= m_data;
		i_fifo_test.m_we    <= m_we;

		i_fifo_test.void <= o_fifo_test.void;
	end procedure fifo_setup_test;
	
	procedure fifo_reset_test (
		signal o_fifo_test  : out o_fifo_test_t
	) is begin
		o_fifo_test.step <= 0;
		o_fifo_test.m_we <= '0';
		o_fifo_test.s_re <= '0';
		o_fifo_test.s_data <= (others => '0');
		o_fifo_test.void <= '0';
		o_fifo_test.s_fill <= (others => 'U');
		o_fifo_test.s_empty <= '1'; -- slave cannot read, now
		o_fifo_test.m_full <= '1';  -- slave cannot write, now
		o_fifo_test.m_rem <= (others => '0'); -- slave will not read while master writes 
	end procedure fifo_reset_test;


	procedure osif_setup_test (
		signal i_osif_test  : out i_osif_test_t;
		signal o_osif_test  : in  o_osif_test_t;
		signal sw2hw_data   : out std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
		signal sw2hw_fill   : out std_logic_vector(15 downto 0);
		signal sw2hw_empty  : out std_logic;
		signal hw2sw_rem    : out std_logic_vector(15 downto 0);
		signal hw2sw_full   : out std_logic;
		signal sw2hw_re     : in  std_logic;
		signal hw2sw_data   : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
		signal hw2sw_we     : in  std_logic
	) is begin
		fifo_setup_test(i_osif_test, o_osif_test, sw2hw_data, sw2hw_fill, sw2hw_empty,
		           hw2sw_rem, hw2sw_full, sw2hw_re, hw2sw_data, hw2sw_we);
	end procedure osif_setup_test;

	procedure osif_reset_test (
		signal o_osif_test  : out o_osif_test_t
	) is begin
		fifo_reset_test(o_osif_test);
	end procedure osif_reset_test;


	procedure memif_setup_test (
		signal i_memif_test   : out i_memif_test_t;
		signal o_memif_test   : in  o_memif_test_t;
		signal mem2hwt_data   : out std_logic_vector(C_MEMIF_WIDTH - 1 downto 0);
		signal mem2hwt_fill   : out std_logic_vector(15 downto 0);
		signal mem2hwt_empty  : out std_logic;
		signal hwt2mem_rem    : out std_logic_vector(15 downto 0);
		signal hwt2mem_full   : out std_logic;
		signal mem2hwt_re     : in  std_logic;
		signal hwt2mem_data   : in  std_logic_vector(C_MEMIF_WIDTH - 1 downto 0);
		signal hwt2mem_we     : in  std_logic
	) is begin
		fifo_setup_test(i_memif_test, o_memif_test, mem2hwt_data, mem2hwt_fill, mem2hwt_empty,
		           hwt2mem_rem, hwt2mem_full, mem2hwt_re, hwt2mem_data, hwt2mem_we);
	end procedure memif_setup_test;
	
	procedure memif_reset_test (
		signal o_memif_test  : out o_memif_test_t
	) is begin
		fifo_reset_test(o_memif_test);
	end procedure memif_reset_test;


	procedure ram_setup_test (
		signal i_ram_test : out i_ram_test_t;
		signal o_ram_test : in  o_ram_test_t;
		signal addr       : in  std_logic_vector(C_MEMIF_WIDTH - 1 downto 0);
		signal we         : in  std_logic;
		signal o_data     : in  std_logic_vector(C_MEMIF_WIDTH - 1 downto 0);
		signal i_data     : out std_logic_vector(C_MEMIF_WIDTH - 1 downto 0)
	) is begin
		i_data <= o_ram_test.data;

		i_ram_test.addr <= addr;
		i_ram_test.we   <= we;
		i_ram_test.data <= o_data;

		i_ram_test.addr        <= o_ram_test.addr;
		i_ram_test.count       <= o_ram_test.count;
		i_ram_test.step        <= o_ram_test.step;
		i_ram_test.remote_addr <= o_ram_test.remote_addr;
		i_ram_test.remainder   <= o_ram_test.remainder;
	end procedure ram_setup_test;
	
	procedure ram_reset_test (
		signal o_ram_test  : out o_ram_test_t
	) is begin
		o_ram_test.addr  <= (others => '0');
		o_ram_test.data  <= (others => '0');
		o_ram_test.count <= (others => '0');
		o_ram_test.step  <= 0;

		o_ram_test.remote_addr <= (others => '0');
		o_ram_test.remainder   <= (others => '0');
	end procedure ram_reset_test;


	-- fifo access functions
	procedure fifo_default_test (
		signal o_fifo_test  : out o_fifo_test_t
	) is begin
		o_fifo_test.s_re <= '0';
		o_fifo_test.m_we <= '0';
	end procedure fifo_default_test;

	procedure expect_fifo_pull_word (
		signal clk          : in  std_logic;
		signal i_fifo_test  : in  i_fifo_test_t;
		signal o_fifo_test  : out o_fifo_test_t;
		constant data       : in  std_logic_vector(C_FIFO_WIDTH - 1 downto 0);
		constant timeout    : in  time := DEFAULT_TIMEOUT
	) is begin
		wait until falling_edge(clk) and i_fifo_test.s_re = '1' for timeout;
		assert i_fifo_test.s_re = '1'
			report "Timeout waiting for the slave to read a word, s_re signal is " & std_logic'image(i_fifo_test.s_re)
			severity failure;

		o_fifo_test.s_empty <= '0';
		o_fifo_test.s_data  <= data;

		wait until rising_edge(clk) for timeout;
		wait until falling_edge(clk) for timeout;

		o_fifo_test.s_empty <= '1';
		o_fifo_test.s_data  <= (others => 'U');
	end procedure expect_fifo_pull_word;

	procedure expect_fifo_push_word (
		signal clk          : in  std_logic;
		signal i_fifo_test  : in  i_fifo_test_t;
		signal o_fifo_test  : out o_fifo_test_t;
		variable data       : out std_logic_vector(C_FIFO_WIDTH - 1 downto 0);
		constant timeout    : in  time := DEFAULT_TIMEOUT
	) is begin
		o_fifo_test.m_full <= '0';

		wait until falling_edge(clk) and i_fifo_test.m_we = '1' for timeout;
		assert i_fifo_test.m_we = '1'
			report "Timeout waiting for word from slave, s_we signal is " & std_logic'image(i_fifo_test.m_we)
			severity failure;

		data := i_fifo_test.m_data;
		o_fifo_test.m_full <= '1';
	end procedure expect_fifo_push_word;

	procedure expect_fifo_pull (
		signal   clk      : in  std_logic;
		signal   i_fifo   : in  i_fifo_test_t;
		signal   o_fifo   : out o_fifo_test_t;
		constant ram      : in  test_memory_t;
		constant addr     : in  natural;
		constant count    : in  natural;
		constant timeout  : in  time := DEFAULT_TIMEOUT
	) is begin
		wait until falling_edge(clk) and i_fifo.s_re = '1' for timeout;
		assert i_fifo.s_re = '1'
			report "Timeout waiting for the slave to read a word, s_re signal is " & std_logic'image(i_fifo.s_re)
			severity failure;

		for i in 0 to count-1 loop
			assert i_fifo.s_re = '1'
				report "Slave doesn't want to read anymore, but we have more data to send."
				severity failure;

			o_fifo.s_empty <= '0';
			o_fifo.s_data  <= ram(addr + i);

			wait until rising_edge(clk) for timeout;
			wait until falling_edge(clk) for timeout;
		end loop;

		-- Even if the slave starts another read immediately, there will be a pause of at least one
		-- clock cycle. If s_re remains high, this means that the slave is reading too much data.
		-- The statemachine of the slave needs one more clock cycle before it actually changes s_re,
		-- so we wait for it to do that.
		wait until rising_edge(clk) for timeout;
		wait until falling_edge(clk) for timeout;
		assert i_fifo.s_re = '0'
			report "Slave wants to read more data, but we don't have any more data at the moment. "
				& "s_re is " & std_logic'image(i_fifo.s_re) & ".";

		o_fifo.s_empty <= '1';
		o_fifo.s_data  <= (others => 'U');
	end procedure expect_fifo_pull;

	procedure expect_fifo_push (
		signal   clk      : in    std_logic;
		signal   i_fifo   : in    i_fifo_test_t;
		signal   o_fifo   : out   o_fifo_test_t;
		variable ram      : inout test_memory_t;
		constant addr     : in    natural;
		constant count    : in    natural; --TODO subtype of natural
		constant timeout  : in    time := DEFAULT_TIMEOUT
	) is begin
		o_fifo.m_full <= '0';
		o_fifo.m_rem <= CONV_STD_LOGIC_VECTOR(count - 1, 16);

		wait until falling_edge(clk) and i_fifo.m_we = '1' for timeout;
		assert i_fifo.m_we = '1'
			report "Timeout waiting for the slave to write a word, m_we signal is " & std_logic'image(i_fifo.m_we)
			severity failure;

		for i in 0 to count-1 loop
			assert i_fifo.m_we = '1'
				report "Slave doesn't want to write anymore, but we expect more data."
				severity failure;

			ram(addr + i) := i_fifo.m_data;

			wait until rising_edge(clk) for timeout;
			wait until falling_edge(clk) for timeout;
		end loop;

		o_fifo.m_full <= '1';
		o_fifo.m_rem  <= (others => 'U');
	end procedure expect_fifo_push;

	procedure expect_osif_read (
		signal clk        : in std_logic;
		signal i_osif     : in  i_osif_test_t;
		signal o_osif     : out o_osif_test_t;
		constant data     : in std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
		constant timeout  : in time := DEFAULT_TIMEOUT
	) is begin
		expect_fifo_pull_word(clk, i_osif, o_osif, data, timeout);
	end procedure expect_osif_read;

	procedure expect_osif_write (
		signal clk        : in  std_logic;
		signal i_osif     : in  i_osif_test_t;
		signal o_osif     : out o_osif_test_t;
		variable data     : out std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
		constant timeout  : in  time := DEFAULT_TIMEOUT
	) is begin
		expect_fifo_push_word(clk, i_osif, o_osif, data, timeout);
	end procedure expect_osif_write;

	function ignore_yield (
		constant call_id : osif_word
	) return osif_word is
		variable result : osif_word;
	begin
		-- This is what we want, but it causes an error during simulation runtime:
		-- return call_id and not OSIF_CMD_YIELD_MASK;
		--TODO why?!?!

		-- Therefore, we use a loop...
		for i in osif_word'range loop
			result(i) := call_id(i) and not OSIF_CMD_YIELD_MASK(i);
		end loop;
		return result;
	end function ignore_yield;

	function CallIdToString(
		constant call_id : in osif_word
	) return string is begin
		case ignore_yield(call_id) is
			when X"000000A0" =>
				return "OSIF_CMD_THREAD_GET_INIT_DATA";
			when X"000000A1" =>
				return "OSIF_CMD_THREAD_DELAY";
			when X"000000A2" =>
				return "OSIF_CMD_THREAD_EXIT";
			when X"000000A3" =>
				return "OSIF_CMD_THREAD_YIELD";
			when X"000000A4" =>
				return "OSIF_CMD_THREAD_RESUME";
			when X"000000A5" =>
				return "OSIF_CMD_THREAD_LOAD_STATE";
			when X"000000A6" =>
				return "OSIF_CMD_THREAD_STORE_STATE";
			when X"000000B0" =>
				return "OSIF_CMD_SEM_POST";
			when X"000000B1" =>
				return "OSIF_CMD_SEM_WAIT";
			when X"000000C0" =>
				return "OSIF_CMD_MUTEX_LOCK";
			when X"000000C1" =>
				return "OSIF_CMD_MUTEX_UNLOCK";
			when X"000000C2" =>
				return "OSIF_CMD_MUTEX_TRYLOCK";
			when X"000000D0" =>
				return "OSIF_CMD_COND_WAIT";
			when X"000000D1" =>
				return "OSIF_CMD_COND_SIGNAL";
			when X"000000D2" =>
				return "OSIF_CMD_COND_BROADCAST";
			when X"000000E0" =>
				return "OSIF_CMD_RQ_RECEIVE";
			when X"000000E1" =>
				return "OSIF_CMD_RQ_SEND";
			when X"000000F0" =>
				return "OSIF_CMD_MBOX_GET";
			when X"000000F1" =>
				return "OSIF_CMD_MBOX_PUT";
			when X"000000F2" =>
				return "OSIF_CMD_MBOX_TRYGET";
			when X"000000F3" =>
				return "OSIF_CMD_MBOX_TRYPUT";
			when others =>
				return to_string(ignore_yield(call_id));
		end case;
	end function CallIdToString;

	procedure assertCallIdEqual(
		constant actual_call_id   : in osif_word;
		constant expected_call_id : in osif_word
	) is begin
		assert ignore_yield(actual_call_id) = expected_call_id
			report "Call ID is " & CallIdToString(actual_call_id) & " instead of " & CallIdToString(expected_call_id)
				& " (" & to_string(ignore_yield(actual_call_id)) & " instead of " & to_string(expected_call_id) & ")"
			severity failure;
	end procedure assertCallIdEqual;

	procedure expect_osif_call_0 (
		signal clk                 : in std_logic;
		signal i_osif              : in  i_osif_test_t;
		signal o_osif              : out o_osif_test_t;
		constant expected_call_id  : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
		constant result            : in std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
		constant timeout           : in time := DEFAULT_TIMEOUT
	) is
		variable actual_call_id : osif_word;
	begin
		expect_fifo_push_word(clk, i_osif, o_osif, actual_call_id, timeout);
		assertCallIdEqual(actual_call_id, expected_call_id);

		expect_fifo_pull_word(clk, i_osif, o_osif, result, timeout);
	end procedure expect_osif_call_0;

	procedure expect_osif_call_1 (
		signal clk                 : in std_logic;
		signal i_osif              : in  i_osif_test_t;
		signal o_osif              : out o_osif_test_t;
		constant expected_call_id  : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
		constant expected_arg0     : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
		constant result            : in std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
		constant timeout           : in time := DEFAULT_TIMEOUT
	) is
		variable tmp : osif_word;
	begin
		expect_fifo_push_word(clk, i_osif, o_osif, tmp, timeout);
		assertCallIdEqual(tmp, expected_call_id);

		expect_fifo_push_word(clk, i_osif, o_osif, tmp, timeout);
		assertEqual(tmp, expected_arg0, "arg0 (expected call id is "
			& CallIdToString(expected_call_id) & " (" & to_string(expected_call_id) & "))");

		expect_fifo_pull_word(clk, i_osif, o_osif, result, timeout);
	end procedure expect_osif_call_1;

	procedure expect_osif_call_1_2 (
		signal clk                 : in  std_logic;
		signal i_osif              : in  i_osif_test_t;
		signal o_osif              : out o_osif_test_t;
		constant expected_call_id  : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
		constant expected_arg0     : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
		constant result1           : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
		constant result2           : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
		constant timeout           : in  time := DEFAULT_TIMEOUT
	) is
		variable tmp : osif_word;
	begin
		expect_fifo_push_word(clk, i_osif, o_osif, tmp, timeout);
		assertCallIdEqual(tmp, expected_call_id);

		expect_fifo_push_word(clk, i_osif, o_osif, tmp, timeout);
		assertEqual(tmp, expected_arg0, "arg0 (expected call id is "
			& CallIdToString(expected_call_id) & " (" & to_string(expected_call_id) & "))");

		expect_fifo_pull_word(clk, i_osif, o_osif, result1, timeout);

		expect_fifo_pull_word(clk, i_osif, o_osif, result2, timeout);
	end procedure expect_osif_call_1_2;

	procedure expect_osif_call_2 (
		signal clk                 : in  std_logic;
		signal i_osif              : in  i_osif_test_t;
		signal o_osif              : out o_osif_test_t;
		constant expected_call_id  : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
		constant expected_arg0     : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
		constant expected_arg1     : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
		constant result            : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
		constant timeout           : in  time := DEFAULT_TIMEOUT
	) is
		variable tmp : osif_word;
	begin
		expect_fifo_push_word(clk, i_osif, o_osif, tmp, timeout);
		assertCallIdEqual(tmp, expected_call_id);

		expect_fifo_push_word(clk, i_osif, o_osif, tmp, timeout);
		assertEqual(tmp, expected_arg0, "arg0 (expected call id is "
			& CallIdToString(expected_call_id) & " (" & to_string(expected_call_id) & "))");

		expect_fifo_push_word(clk, i_osif, o_osif, tmp, timeout);
		assertEqual(tmp, expected_arg1, "arg1 (expected call id is "
			& CallIdToString(expected_call_id) & " (" & to_string(expected_call_id) & "))");

		expect_fifo_pull_word(clk, i_osif, o_osif, result, timeout);
	end procedure expect_osif_call_2;

	procedure expect_osif_sem_post (
		signal   clk     : in  std_logic;
		signal   i_osif  : in  i_osif_test_t;
		signal   o_osif  : out o_osif_test_t;
		constant handle  : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
		constant result  : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0) := (others => '0');
		constant timeout : in  time := DEFAULT_TIMEOUT
	) is
	begin
		expect_osif_call_1(clk, i_osif, o_osif, OSIF_CMD_SEM_POST, handle, result, timeout);
	end procedure expect_osif_sem_post;

	procedure expect_osif_sem_wait (
		signal   clk     : in  std_logic;
		signal   i_osif  : in  i_osif_test_t;
		signal   o_osif  : out o_osif_test_t;
		constant handle  : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
		constant result  : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0) := (others => '0');
		constant timeout : in  time := DEFAULT_TIMEOUT
	) is
	begin
		expect_osif_call_1(clk, i_osif, o_osif, OSIF_CMD_SEM_WAIT, handle, result, timeout);
	end procedure expect_osif_sem_wait;

	procedure expect_osif_mbox_put (
		signal clk       : in  std_logic;
		signal i_osif    : in  i_osif_test_t;
		signal o_osif    : out o_osif_test_t;
		constant handle  : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
		constant word    : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
		constant result  : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0) := (others => '0');
		constant timeout : in  time := DEFAULT_TIMEOUT
	) is begin
		expect_osif_call_2(clk, i_osif, o_osif, OSIF_CMD_MBOX_PUT, handle, word, result, timeout);
	end procedure expect_osif_mbox_put;

	procedure expect_osif_mbox_get (
		signal clk       : in  std_logic;
		signal i_osif    : in  i_osif_test_t;
		signal o_osif    : out o_osif_test_t;
		constant handle  : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
		constant result  : in  std_logic_vector(C_OSIF_WIDTH - 1 downto 0);
		constant timeout : in  time := DEFAULT_TIMEOUT
	) is begin
		expect_osif_call_1(clk, i_osif, o_osif, OSIF_CMD_MBOX_GET, handle, result, timeout);
	end procedure expect_osif_mbox_get;


	procedure expect_osif_thread_exit (
		signal   clk     : in  std_logic;
		signal   i_osif  : in  i_osif_test_t;
		signal   o_osif  : out o_osif_test_t;
		constant timeout : in  time := DEFAULT_TIMEOUT
	) is
		variable tmp : osif_word;
	begin
		expect_fifo_push_word(clk, i_osif, o_osif, tmp, timeout);
		assertEqual(tmp, OSIF_CMD_THREAD_EXIT, "call id should be OSIF_CMD_THREAD_EXIT");
	end procedure expect_osif_thread_exit;


	--memif functions

	procedure acknowledge_memif_flush (
		signal   clk     : in  std_logic;
		signal   i_memif : in  i_memif_test_t;
		signal   o_memif : out o_memif_test_t;
		constant timeout : in  time := DEFAULT_TIMEOUT
	) is begin
		wait until falling_edge(clk) for timeout;

		o_memif.m_rem <= X"007F";
		o_memif.m_full <= '0';

		wait until rising_edge(clk) for timeout;
		wait until falling_edge(clk) for timeout;

		o_memif.m_full <= '1';
	end procedure acknowledge_memif_flush;

	procedure expect_memif_write_word (
		signal   clk     : in  std_logic;
		signal   i_memif : in  i_memif_test_t;
		signal   o_memif : out o_memif_test_t;
		constant addr    : in  std_logic_vector(31 downto 0);
		variable data    : out  std_logic_vector(31 downto 0);
		constant timeout : in  time := DEFAULT_TIMEOUT
	) is
		variable tmp : osif_word;
	begin
		expect_fifo_push_word(clk, i_memif, o_memif, tmp, timeout);
		assertEqual(tmp, MEMIF_CMD_WRITE & X"000004", "expected MEM_IF_CMD_WRITE with length 4");
		expect_fifo_push_word(clk, i_memif, o_memif, tmp, timeout);
		assertEqual(tmp, addr, "memory address for writing a word");
		expect_fifo_push_word(clk, i_memif, o_memif, data, timeout);
	end procedure expect_memif_write_word;

	procedure expect_memif_read_word (
		signal   clk     : in  std_logic;
		signal   i_memif : in  i_memif_test_t;
		signal   o_memif : out o_memif_test_t;
		constant addr    : in  std_logic_vector(31 downto 0);
		constant data    : in  std_logic_vector(31 downto 0);
		constant timeout : in  time := DEFAULT_TIMEOUT
	) is
		variable tmp : osif_word;
	begin
		expect_fifo_push_word(clk, i_memif, o_memif, tmp, timeout);
		assertEqual(tmp, MEMIF_CMD_READ & X"000004", "expected MEMIF_CMD_READ with length 4");
		expect_fifo_push_word(clk, i_memif, o_memif, tmp, timeout);
		assertEqual(tmp, addr, "memory address for reading a word");
		expect_fifo_pull_word(clk, i_memif, o_memif, data, timeout);
	end procedure expect_memif_read_word;

	function to_addr(constant addr : natural) return osif_word is
	begin
		return CONV_STD_LOGIC_VECTOR(addr, C_MEMIF_WIDTH);
	end function to_addr;

	subtype memif_len_t is std_logic_vector(C_MEMIF_LENGTH_WIDTH - 1 downto 0);

	function to_memif_length(constant len : natural) return memif_len_t is
	begin
		return CONV_STD_LOGIC_VECTOR(len, C_MEMIF_LENGTH_WIDTH);
	end function to_memif_length;

	function floor(constant x : natural) return natural is
	begin
		return x;
	end function floor;

	procedure expect_memif_write (
		signal   clk      : in    std_logic;
		signal   i_memif  : in    i_memif_test_t;
		signal   o_memif  : out   o_memif_test_t;
		constant dst_addr : in    natural;
		constant len      : in    natural;
		variable ram      : inout test_memory_t;
		constant ram_addr : in    natural := 0;
		constant timeout  : in    time := DEFAULT_TIMEOUT
	) is
		variable tmp : osif_word;
	begin
		assert len mod 4 = 0
			report "Memory access length must be a multiple of 4. The hardware will use floor(len/4)*4.";

		if len > C_CHUNK_SIZE_BYTES then
			for i in 0 to floor(len/C_CHUNK_SIZE_BYTES)-1 loop
				expect_memif_write(clk, i_memif, o_memif,
					dst_addr + i*C_CHUNK_SIZE_BYTES,
					C_CHUNK_SIZE_BYTES,
					ram,
					ram_addr + i*C_CHUNK_SIZE,
					timeout);
			end loop;
			if len mod C_CHUNK_SIZE_BYTES > 0 then
				expect_memif_write(clk, i_memif, o_memif,
					dst_addr + floor(len/C_CHUNK_SIZE_BYTES)*C_CHUNK_SIZE_BYTES,
					len mod C_CHUNK_SIZE_BYTES,
					ram,
					ram_addr + floor(len/C_CHUNK_SIZE_BYTES)*C_CHUNK_SIZE,
					timeout);
			end if;
		else
			expect_fifo_push_word(clk, i_memif, o_memif, tmp, timeout);
			assertEqual(tmp, MEMIF_CMD_WRITE & to_memif_length(len), "expected MEM_IF_CMD_WRITE with length " & integer'image(len));
			expect_fifo_push_word(clk, i_memif, o_memif, tmp, timeout);
			assertEqual(tmp, to_addr(dst_addr), "memory address for writing data");

			expect_fifo_push(clk, i_memif, o_memif, ram, ram_addr, len/4);
		end if;
	end procedure expect_memif_write;

	procedure expect_memif_read (
		signal   clk      : in  std_logic;
		signal   i_memif  : in  i_memif_test_t;
		signal   o_memif  : out o_memif_test_t;
		constant src_addr : in  natural;
		constant len      : in  natural;
		constant ram      : in  test_memory_t;
		constant ram_addr : in  natural := 0;
		constant timeout  : in  time := DEFAULT_TIMEOUT
	) is
		variable tmp : osif_word;
	begin
		assert len mod 4 = 0
			report "Memory access length must be a multiple of 4. The hardware will use floor(len/4)*4.";

		if len > C_CHUNK_SIZE_BYTES then
			for i in 0 to floor(len/C_CHUNK_SIZE_BYTES)-1 loop
				expect_memif_read(clk, i_memif, o_memif,
					src_addr + i*C_CHUNK_SIZE_BYTES,
					C_CHUNK_SIZE_BYTES,
					ram,
					ram_addr + i*C_CHUNK_SIZE,
					timeout);
			end loop;
			if len mod C_CHUNK_SIZE_BYTES > 0 then
				expect_memif_read(clk, i_memif, o_memif,
					src_addr + floor(len/C_CHUNK_SIZE_BYTES)*C_CHUNK_SIZE_BYTES,
					len mod C_CHUNK_SIZE_BYTES,
					ram,
					ram_addr + floor(len/C_CHUNK_SIZE_BYTES)*C_CHUNK_SIZE,
					timeout);
			end if;
		else
			expect_fifo_push_word(clk, i_memif, o_memif, tmp, timeout);
			assertEqual(tmp, MEMIF_CMD_READ & to_memif_length(len), "expected MEMIF_CMD_READ with length " & integer'image(len));
			expect_fifo_push_word(clk, i_memif, o_memif, tmp, timeout);
			assertEqual(tmp, to_addr(src_addr), "memory address for reading data");

			expect_fifo_pull(clk, i_memif, o_memif, ram, ram_addr, len/4);
		end if;
	end procedure expect_memif_read;

end package body reconos_test_pkg;
