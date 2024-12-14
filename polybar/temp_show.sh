#!/bin/bash

input=$(sensors)

# Extract temperatures from the sensors output
cpu_temp=$(echo "$input" | awk '/Tccd1:/ {print $2}' | tr -d '+°C')
gpu_temp=$(echo "$input" | awk '/junction/ {print $2}' | tr -d '+°C')
gpu_rpm=$(echo "$input" | awk '/fan1/ {print $2}' | tr -d ' RPM')
ram1_temp=$(echo "$input" | awk '/spd5118-i2c-1-51/ {getline; getline; print $2}' | tr -d '+°C')
ram2_temp=$(echo "$input" | awk '/spd5118-i2c-1-53/ {getline; getline; print $2}' | tr -d '+°C')
disk_temp=$(echo "$input" | awk '/nvme-pci-0400/ {getline; getline; print $2}' | tr -d '+°C')

# Format the output
output="cpu $cpu_temp   •   gpu $gpu_temp/rpm $gpu_rpm   •  ram1 $ram1_temp   •   ram2 $ram2_temp   •   disk $disk_temp"

# Print the output
echo "$output"
