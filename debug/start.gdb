# reload the binary
define reset
	print "Resetting qemu"
	monitor system_reset
	load
end

# some breakpoints
b _ARM_Exception_default
b _ARMV4_Exception_data_abort_default
b bsp_interrupt_handler_default
b bsp_reset
b rtems_bsd_assert_func
b _bsd_panic
b _Internal_error_Occurred
b _Terminate

target remote :1234
