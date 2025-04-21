#!/bin/bash

# Usage: ./stealth_enum.sh <target IP or subnet>
# Example: ./stealth_enum.sh 10.129.2.18

TARGET=$1
TIMESTAMP=$(date +"%Y%m%d_%H%M")
OUTPUT_DIR="nmap_scan_$TARGET_$TIMESTAMP"

mkdir -p "$OUTPUT_DIR"
echo "[*] Scanning $TARGET - results will be stored in $OUTPUT_DIR"

# Phase 1: Host Discovery (Ping Scan)
echo "[*] Phase 1: Host discovery"
nmap -sn -n -T2 "$TARGET" -oN "$OUTPUT_DIR/phase1_ping.txt"

# Phase 2: Top 1000 Ports Scan
echo "[*] Phase 2: Top 1000 ports + service detection"
nmap -Pn -sS -T2 -sV --script=default "$TARGET" -oN "$OUTPUT_DIR/phase2_top1000.txt"

# Phase 3: Full TCP Port Scan (65535)
echo "[*] Phase 3: Full port scan"
nmap -Pn -sS -p- -T2 "$TARGET" -oN "$OUTPUT_DIR/phase3_fullport.txt"

# Extract open ports for next phase
echo "[*] Extracting open ports..."
OPEN_PORTS=$(grep -oP '^\d+/tcp\s+open' "$OUTPUT_DIR/phase3_fullport.txt" | cut -d '/' -f1 | paste -sd, -)

if [[ -z "$OPEN_PORTS" ]]; then
    echo "[!] No open ports found in full port scan. Skipping phase 4 and 5."
else
    # Phase 4: Deep Service Version Detection on open ports
    echo "[*] Phase 4: Service detection on open ports: $OPEN_PORTS"
    nmap -Pn -sV -p "$OPEN_PORTS" "$TARGET" -oN "$OUTPUT_DIR/phase4_servicedetect.txt"

    # Phase 5: Targeted NSE Scripts
    echo "[*] Phase 5: Targeted NSE scripts"
    nmap -Pn --script=http-title,smb-os-discovery,vuln -p "$OPEN_PORTS" "$TARGET" -oN "$OUTPUT_DIR/phase5_nse.txt"
fi

# Phase 6: OS Detection (Loud)
echo "[*] Phase 6: OS Detection"
nmap -Pn -O --osscan-limit --osscan-guess "$TARGET" -oN "$OUTPUT_DIR/phase6_osdetect.txt"

echo "[+] Scan complete! Check results in: $OUTPUT_DIR"
