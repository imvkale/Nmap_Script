#!/bin/bash

# Usage: ./stealth_enum.sh <target IP or subnet>
# Example: ./stealth_enum.sh 10.129.2.18

TARGET=$1
TIMESTAMP=$(date +"%Y%m%d_%H%M")
OUTPUT_DIR="nmap_scan_$TARGET_$TIMESTAMP"

mkdir -p "$OUTPUT_DIR"
echo "[*] Scanning $TARGET - results will be stored in $OUTPUT_DIR"

# Phase 1: Host Discovery
echo "[*] Phase 1: Host discovery"
nmap -sn -n -T2 "$TARGET" -oN "$OUTPUT_DIR/phase1_ping.txt"

# Phase 2: Top 1000 Ports Scan
echo "[*] Phase 2: Top 1000 ports + service detection"
nmap -Pn -sS -T2 -sV --script=default "$TARGET" -oN "$OUTPUT_DIR/phase2_top1000.txt"

# Phase 3: Full Port Scan
echo "[*] Phase 3: Full port scan"
nmap -Pn -sS -p- -T2 "$TARGET" -oN "$OUTPUT_DIR/phase3_fullport.txt"

# Extract open ports
echo "[*] Extracting open ports..."
OPEN_PORTS=$(grep -oP '^\d+/tcp\s+open' "$OUTPUT_DIR/phase3_fullport.txt" | cut -d '/' -f1 | paste -sd, -)

if [[ -z "$OPEN_PORTS" ]]; then
    echo "[!] No open ports found in full port scan. Skipping next phases."
    exit 1
fi

# Phase 4: Service Detection
echo "[*] Phase 4: Deep service detection on ports: $OPEN_PORTS"
nmap -Pn -sV -p "$OPEN_PORTS" "$TARGET" -oN "$OUTPUT_DIR/phase4_servicedetect.txt"

# Phase 5: NSE Scripts
echo "[*] Phase 5: Targeted NSE scripts"
nmap -Pn --script=http-title,smb-os-discovery -p "$OPEN_PORTS" "$TARGET" -oN "$OUTPUT_DIR/phase5_nse.txt"

# Phase 5b: Vulnerability Scripts (Optional & Aggressive)
echo "[*] Phase 5b: NSE vulnerability scan (aggressive)"
nmap -Pn --script vuln -p "$OPEN_PORTS" "$TARGET" -oN "$OUTPUT_DIR/phase5b_vuln.txt"

# Phase 6: OS Detection
echo "[*] Phase 6: OS detection"
nmap -Pn -O --osscan-limit --osscan-guess "$TARGET" -oN "$OUTPUT_DIR/phase6_osdetect.txt"

# Phase 7: Netcat Enumeration
echo "[*] Phase 7: Netcat banner grab on open ports"
NC_OUTPUT="$OUTPUT_DIR/phase7_netcat_banners.txt"
IFS=',' read -ra PORTS <<< "$OPEN_PORTS"

for port in "${PORTS[@]}"; do
    echo -e "\n[+] Connecting to $TARGET:$port ..." >> "$NC_OUTPUT"
    echo "" | nc -nv "$TARGET" "$port" -w 3 >> "$NC_OUTPUT" 2>&1
done

echo "[+] Scan complete! All results are saved in: $OUTPUT_DIR"
