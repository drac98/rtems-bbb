define reset
	monitor halt
	monitor reset
	load
end

target remote :2331
