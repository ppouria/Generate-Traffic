#!/bin/bash

clear

read -p "Enter the download URL: " DOWNLOAD_URL
read -p "Enter the number of parallel downloads [100]: " PARALLEL
PARALLEL=${PARALLEL:-100}
read -p "Enter the total traffic to generate (e.g., 1TB, 500GB): " TOTAL_TRAFFIC
TOTAL_TRAFFIC=${TOTAL_TRAFFIC:-100GB}

# Function to convert traffic input to megabytes
convert_to_mb() {
    local input=$1
    local number=$(echo "$input" | grep -oP '^\d+(\.\d+)?')
    local unit=$(echo "$input" | grep -oP '[A-Za-z]+$' | tr '[:upper:]' '[:lower:]')

    case "$unit" in
        tb)
            echo "$(echo "$number * 1024 * 1024" | bc)"
            ;;
        gb)
            echo "$(echo "$number * 1024" | bc)"
            ;;
        mb)
            echo "$number"
            ;;
        *)
            echo "0"
            ;;
    esac
}

TOTAL_TRAFFIC_MB=$(convert_to_mb "$TOTAL_TRAFFIC")

# Get file size in bytes
FILE_SIZE_BYTES=$(curl -sI "$DOWNLOAD_URL" | grep -i "Content-Length" | awk '{print $2}' | tr -d '\r')
if [ -z "$FILE_SIZE_BYTES" ]; then
    echo "Could not determine file size. Please enter the file size in MB:"
    read -p "File size [1200MB]: " FILE_SIZE_MB
    FILE_SIZE_MB=${FILE_SIZE_MB:-1200}
else
    FILE_SIZE_MB=$(echo "$FILE_SIZE_BYTES / 1048576" | bc)
fi

DOWNLOADS_REQUIRED=$(echo "scale=0; ($TOTAL_TRAFFIC_MB / $FILE_SIZE_MB)" | bc)
if [ "$DOWNLOADS_REQUIRED" -lt 1 ]; then
    DOWNLOADS_REQUIRED=1
fi

DOWNLOADS_PER_THREAD=$(echo "$DOWNLOADS_REQUIRED / $PARALLEL" | bc)
REMAINDER=$(echo "$DOWNLOADS_REQUIRED % $PARALLEL" | bc)

if [ "$DOWNLOADS_PER_THREAD" -lt 1 ]; then
    PARALLEL=$DOWNLOADS_REQUIRED
    DOWNLOADS_PER_THREAD=1
fi

trap "kill 0; rm -f /tmp/download_counter.txt; exit 1" SIGINT

echo 0 > /tmp/download_counter.txt

for ((i=1;i<=PARALLEL;i++))
do
    (
        for ((j=1;j<=DOWNLOADS_PER_THREAD;j++))
        do
            wget -q --no-check-certificate -O /dev/null "$DOWNLOAD_URL" && echo "1" >> /tmp/download_counter.txt
        done
    ) &
done

if [ "$REMAINDER" -gt 0 ]; then
    for ((i=1;i<=REMAINDER;i++))
    do
        (
            wget -q --no-check-certificate -O /dev/null "$DOWNLOAD_URL" && echo "1" >> /tmp/download_counter.txt
        ) &
    done
fi

while [ "$(wc -l < /tmp/download_counter.txt)" -lt "$DOWNLOADS_REQUIRED" ]
do
    COMPLETED=$(wc -l < /tmp/download_counter.txt)
    PERCENT=$(awk "BEGIN {printf \"%.2f\", ($COMPLETED/$DOWNLOADS_REQUIRED)*100}")
    echo -ne "Progress: $PERCENT% ($COMPLETED/$DOWNLOADS_REQUIRED)\r"
    sleep 1
done
echo -ne "Progress: 100% ($DOWNLOADS_REQUIRED/$DOWNLOADS_REQUIRED)\n"

wait
rm -f /tmp/download_counter.txt

sudo apt update
sudo apt install -y btop
btop
