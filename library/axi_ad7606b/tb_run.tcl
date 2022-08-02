run 40 ns
add_force {/axi_ad7606_tb/i_ad7606_tb/i_ad7606_regmap/up_cnvst_en} -radix hex {1 0ns}
add_force {/axi_ad7606_tb/i_ad7606_tb/i_ad7606_regmap/up_conv_rate} -radix hex {80 0ns}
run 40 ns
add_force {/axi_ad7606_tb/i_ad7606_tb/i_ad7606_regmap/up_resetn} -radix hex {1 0ns}
run 1000 ns
