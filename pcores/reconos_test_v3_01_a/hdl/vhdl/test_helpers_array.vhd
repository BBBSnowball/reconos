LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;

library reconos_test_v3_01_a;
use reconos_test_v3_01_a.test_helpers.all;

package test_helpers_array is
  type array_of_std_logic_vector is array (integer range <>) of std_logic_vector(31 downto 0);
  procedure assertEqual(actual   : in array_of_std_logic_vector;
                        expected : in array_of_std_logic_vector);

end package test_helpers_array;

package body test_helpers_array is

  procedure assertEqual(actual   : in array_of_std_logic_vector;
                        expected : in array_of_std_logic_vector) is
    variable index_a, index_e : integer;
    variable item_a,  item_e  : std_logic_vector(expected(0)'range);
  begin
    assert actual'length = expected'length
      report "Error comparing arrays of different length: " & integer'image(actual'length) & " vs. " & integer'image(expected'length);

    for i in 0 to actual'length-1 loop
      index_a := actual'low   + i;
      index_e := expected'low + i;
      item_a  := actual(index_a);
      item_e  := expected(index_e);

      assert item_a = item_e
        report "actual(" & integer'image(index_a) & ") = " & to_string(item_a)
          & "  /=  " & to_string(item_e) & " = expected(" & integer'image(index_e) & ")";
    end loop;
  end procedure assertEqual;

end package body test_helpers_array;
