restart -all
vsim -gui work.cpu
mem load -i D:/CUFE_Courses/3-Senior1/Spring2023/CMPN301_Computer-Architecture/Project/Code/Instructions.mem /cpu/fetch1/line__56/Cache
add wave -position insertpoint sim:/cpu/*
force -freeze sim:/cpu/clk 1 0, 0 {50 ps} -r 100
force -freeze sim:/cpu/rst 1 0
run
force -freeze sim:/cpu/rst 0 1
force -freeze sim:/cpu/InPort FFFE 0
run
run
run
run
run
run
run
run
run
run
force -freeze sim:/cpu/InPort 0001 0
run
force -freeze sim:/cpu/InPort 000F 0
run
force -freeze sim:/cpu/InPort 00C8 0
run
force -freeze sim:/cpu/InPort 001F 0
run
force -freeze sim:/cpu/InPort 00FC 0
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run