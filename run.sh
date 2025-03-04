#!/bin/bash -e

date
source /root/nfs_stats/vars.cfg

# Write header if file doesn't exist
if [ ! -f "$CSV_OUT" ]; then
    echo "timestamp,loadavg_1,loadavg_5,loadavg_15,find_d1,find_all,rsync_1,rsync_5" > "$CSV_OUT"
fi

# Function to measure execution time
measure_time() {
    local start_time end_time
    start_time=$(date +%s.%N)
    "$@" > /dev/null # Throw away command output
    end_time=$(date +%s.%N)
    #echo "$(echo "$end_time - $start_time" | bc)"
    printf %.2f "$(echo "$end_time - $start_time" | bc)"
}

# Create timestamp
timestamp=$(date +"%Y-%m-%d %H:%M:%S")


# Get load averages
echo "Getting load averages"
read loadavg_1 loadavg_5 loadavg_15 _ < /proc/loadavg


# Measure find commands
echo "Measuring find commands"
echo "find "$FIND_DIR" -mindepth 1 -maxdepth 1"
find_d1=$(measure_time find "$FIND_DIR" -mindepth 1 -maxdepth 1)
echo "find "$FIND_DIR""
find_all=$(measure_time find "$FIND_DIR")
date


# Measure rsync time for single directory
echo "Recreating RSYNC_DIR/dest directories"

for i in $(seq 1 5); do
    echo $RSYNC_DIR/dest$i
    rm -rf $RSYNC_DIR/dest$i
    mkdir -p $RSYNC_DIR/dest$i
done

echo "Rsyncing single directory"
echo "rsync -a "$RSYNC_DIR/source1" "$RSYNC_DIR/dest1""
rsync_1=$(measure_time rsync -a "$RSYNC_DIR/source1" "$RSYNC_DIR/dest1")


# Measure rsync time for multiple directories in parallel
echo "Rsyncing multiple directories in parallel"
start_rsync_5=$(date +%s.%N)
for i in $(seq 1 5); do
    echo "rsync -a "$RSYNC_DIR/source$i" "$RSYNC_DIR/dest$i" &"
    rsync -a "$RSYNC_DIR/source$i" "$RSYNC_DIR/dest$i" &
done
wait
end_rsync_5=$(date +%s.%N)
rsync_5=$(echo "$end_rsync_5 - $start_rsync_5" | bc)
date

# Append results to CSV file
echo "$timestamp,$loadavg_1,$loadavg_5,$loadavg_15,$find_d1,$find_all,$rsync_1,$rsync_5" >> "$CSV_OUT"

echo "NFS metrics recorded in $CSV_OUT"
