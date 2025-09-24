#!/bin/bash
STORCLI_PATH="/opt/MegaRAID/storcli/storcli64"

echo "# HELP hpe_sr_disk_status Disk physical drive status (0=OK, 1=FAIL, 2=PREDICTIVE_FAIL)"
echo "# TYPE hpe_sr_disk_status gauge"

for CTRL_ID in 0 1; do
    $STORCLI_PATH /c${CTRL_ID}/eall/sall show 2>/dev/null | grep -E '^[0-9]+' | while read line; do
        disk_id=$(echo "$line" | awk '{print $3}')
        status=$(echo "$line" | awk '{print $4}')

        case "$status" in
            "Onln"|"UGood") val=0 ;;
            "Offln"|"Failed") val=1 ;;
            "PFail") val=2 ;;
            *) val=3 ;;
        esac

        status_clean=$(echo "$status" | tr -d ',')
        echo "hpe_sr_disk_status{controller=\"${CTRL_ID}\",disk=\"$disk_id\",status=\"$status_clean\"} $val"
    done
done
