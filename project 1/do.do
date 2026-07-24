vlib work
vmap work work
vlog *.v
vsim ITIBQS
add wave -r sim:/ITIBQS/*
force -freeze sim:/ITIBQS/rstn 0 0
force -freeze sim:/ITIBQS/clk 1 0, 0 {50 ns} -r 100
force -freeze sim:/ITIBQS/frontSensorInput 1 0
force -freeze sim:/ITIBQS/backSensorInput 1 0
force -freeze sim:/ITIBQS/tellers 011 0
run
force -freeze sim:/ITIBQS/rstn 1 0
run
force -freeze sim:/ITIBQS/frontSensorInput 0 0, 0 {210 ns} -r 400
run 500
noforce sim:/ITIBQS/frontSensorInput
force -freeze sim:/ITIBQS/frontSensorInput 1 0
force -freeze sim:/ITIBQS/backSensorInput 0 0, 0 {440 ns} -r 800
run 500
noforce sim:/ITIBQS/backSensorInput
force -freeze sim:/ITIBQS/backSensorInput St0 0
run 1000
force -freeze sim:/ITIBQS/frontSensorInput 0 0
run 2000
force -freeze sim:/ITIBQS/backSensorInput 1 0, 0 {220 ns} -r 400
run 5000

