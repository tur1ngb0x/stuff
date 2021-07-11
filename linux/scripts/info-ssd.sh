#!/bin/bash

#######################################
# Variables                           #
#######################################

SSD_DEVICE="/dev/sda"

ON_TIME_TAG="Power_On_Hours"
WEAR_COUNT_TAG="Wear_Leveling_Count"
LBAS_WRITTEN_TAG="Total_LBAs_Written"
LBA_SIZE=512 # Value in bytes

BYTES_PER_MB=1048576
BYTES_PER_GB=1073741824
BYTES_PER_TB=1099511627776

separator()
{
	echo ""
}

# Get SMART Info
SMART_INFO=$(sudo /usr/sbin/smartctl -A "$SSD_DEVICE")

# Extract Attributes
ON_TIME=$(echo "$SMART_INFO" | grep "$ON_TIME_TAG" | awk '{print $10}')
WEAR_COUNT=$(echo "$SMART_INFO" | grep "$WEAR_COUNT_TAG" | awk '{print $4}' | sed 's/^0*//')
LBAS_WRITTEN=$(echo "$SMART_INFO" | grep "$LBAS_WRITTEN_TAG" | awk '{print $10}')

# Convert LBAs to MB,GB<TB
BYTES_WRITTEN=$(echo "$LBAS_WRITTEN * $LBA_SIZE" | bc)
MB_WRITTEN=$(echo "scale=3; $BYTES_WRITTEN / $BYTES_PER_MB" | bc)
GB_WRITTEN=$(echo "scale=3; $BYTES_WRITTEN / $BYTES_PER_GB" | bc)
TB_WRITTEN=$(echo "scale=3; $BYTES_WRITTEN / $BYTES_PER_TB" | bc)

separator
sudo /usr/sbin/smartctl -A /dev/sda | tail -n +7 | column -t
separator

echo "SSD Device: $SSD_DEVICE"
separator

echo "Drive Health: ${WEAR_COUNT}%"
separator

echo "Power ON Time"
POWER_ON_HRS="$(echo "$ON_TIME" | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta')"
POWER_ON_DYS="$(echo "$ON_TIME" / 24 | bc | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta')"
printf " Hours: $POWER_ON_HRS\n"
printf " Days: $POWER_ON_DYS\n"
separator

echo "Total Data Written"
echo " MB: $(echo "$MB_WRITTEN" | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta')"
echo " GB: $(echo "$GB_WRITTEN" | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta')"
echo " TB: $(echo "$TB_WRITTEN" | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta')"
separator

echo "Mean Write Rate"
echo " $(echo "scale=3; $GB_WRITTEN / $ON_TIME" | bc | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta') GB per hour"
echo " $(echo "scale=3; $GB_WRITTEN / $ON_TIME * 24" | bc | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta') GB per day"
separator
