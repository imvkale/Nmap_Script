# Nmap_Script

I have made a Bash script that automates the 6-phase Nmap scanning strategy

Phase 1: Host Discovery
Identify live hosts without port scanning.

Phase 2: Quick Top 100 Ports
Get fast intel on common services.

Phase 3: Full Port Scan (All 65535 Ports)
Find hidden services.

Phase 4: Deep Service Version Detection
Only scan ports you found open in Phase 3

Phase 5: Targeted Script Scan
Run only specific, relevant scripts (safely)

Phase 6: OS Detection
This is the loudest phase and often triggers IDS/IPS

Phase 7: Netcat Enumeration
This will give you extra info through netcat

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


