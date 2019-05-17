#!/bin/bash
clock=143000000
# clock=135000000
cat nmr.bit >/dev/xdevcfg
devcfg=/sys/devices/soc0/amba/f8007000.devcfg
echo "Export FCLK0"
echo fclk0 > $devcfg/fclk_export
echo "Enabling FCLK0"
echo 1 > $devcfg/fclk/fclk0/enable
echo "Set FCLK0" $clock
echo $clock > $devcfg/fclk/fclk0/set_rate
echo "Clock:"
cat $devcfg/fclk/fclk0/set_rate
