vlib work 
vmap work work
vlog *.v
vsim JohnsonCounter
add wave sim:/JohnsonCounter/*
force -freeze sim:/JohnsonCounter/rstn 0 0
force -freeze sim:/JohnsonCounter/clk 1 0, 0 {50 ps} -r 100
run
run
run
force -freeze sim:/JohnsonCounter/rstn 1 0
run
run
run
run
run
