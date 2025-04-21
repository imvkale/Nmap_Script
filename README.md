# Nmap_Script

I Have made a Bash script which will 


1. Save the script: nano stealth_enum.sh
2. Make it executable: chmod +x stealth_enum.sh
3. Run it: ./stealth_enum.sh 10.129.2.18
4. Each phase will be saved as a separate file under a timestamped folder, like:

   
   nmap_scan_10.129.2.18_20250416/
├── phase1_ping.txt
├── phase2_top1000.txt
├── phase3_fullport.txt
├── phase4_servicedetect.txt
├── phase5_nse.txt
└── phase6_osdetect.txt


