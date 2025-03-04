# XNAT NFS Benchmark  

This repository provides scripts to help test and monitor the performance of an NFS-mounted XNAT archive.  

## Setup  

1. **Configure Environment Variable**  
   - Set your NFS-mounted XNAT path in `vars.cfg`. 
      - This is where your generated data will be stored and read from.
      - E.g., you could use the XNAT cache path
   - Set the path for the csv output.

2. **Set Up Python Environment**  
   - Create a virtual environment and install dependencies:  
     ```bash
     python -m venv venv
     source venv/bin/activate
     pip install -r requirements.txt
     ```  

## Run  

1. **Generate Directory Tree**  
   - Modify the `generate_tree` function arguments in `tree.sh` to adjust the directory shape and file sizes.  
   - Example: Create **10K top-level directories** with **10 SCANS**, each containing **two 1KB files**.
     ```bash
     generate_tree "$BASE_DIR/find" 10000 10 2 1
     ``` 
   - Run the `tree.sh` script to create the directory tree on your storage:  
     ```bash
     ./tree.sh
     ```    

2. **Run Benchmarks**  
   - Execute `run.sh` to verify everything is set up correctly:  
     ```bash
     ./run.sh
     ```  

3. **Automate Execution**  
   - Set up an orchestration job to execute `run.sh` at your desired interval (e.g., hourly).  
   - Before automating, run it manually to monitor system load.  
   - Use this test run to determine the best execution frequency for your orchestration tool (e.g., cron).  

4. **Plot Results**  
   - Visualize the output locally using `plot.py`:  
     ```bash
     python plot.py fs_stats.csv --save chart.png
     ```  
