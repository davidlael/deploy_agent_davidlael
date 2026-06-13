#!/bin/bash

# =======================================================================
# Project: Automated Project Bootstrapping & Process Management
# Script Name: setup_project.sh
# Description: Automates workspace creation, dynamic JSON configuration,
#              environment validation, and robust SIGINT process handling.
# =======================================================================

# --- 1. SIGNAL TRAP IMPLEMENTATION (Process Management & Error Cleanup) ---
cleanup_trap() {
    echo -e "\n\n[!] SIGINT (Ctrl+C) detected! Initiating emergency cleanup sequence..."
    if [ -n "$TARGET_DIR" ] && [ -d "$TARGET_DIR" ]; then
        echo "[*] Bundling partial project state into an archive..."
        ARCHIVE_NAME="${TARGET_DIR}_archive"
        tar -czf "${ARCHIVE_NAME}.tar.gz" "$TARGET_DIR" 2>/dev/null
        echo "[+] Archive successfully created: ${ARCHIVE_NAME}.tar.gz"
        echo "[*] Cleaning up incomplete directory to keep workspace spotless..."
        rm -rf "$TARGET_DIR"
        echo "[+] Incomplete directory removed safely."
    else
        echo "[-] Target directory was not created yet. Nothing to archive/clean."
    fi
    echo -e "[!] Exiting securely. Goodbye.\n"
    exit 1
}
trap 'cleanup_trap' SIGINT

# --- 2. INPUT ACQUISITION & WORKSPACE SETUP (Directory & Automation) ---
echo "===================================================="
echo "    AUTOMATED ATTENDANCE TRACKER PROJECT FACTORY     "
echo "===================================================="

read -p "Enter a unique identifier for your tracker workspace: " USER_INPUT

# Sanitize input: Ensure it's not empty and contains valid directory characters
if [ -z "$USER_INPUT" ] || [[ "$USER_INPUT" =~ [^a-zA-Z0-9_-] ]]; then
    echo "[X] Error: Identifier must be alphanumeric and cannot be empty."
    exit 1
fi

TARGET_DIR="attendance_tracker_${USER_INPUT}"
echo -e "\n[*] Initializing directory architecture for: $TARGET_DIR..."

if [ -d "$TARGET_DIR" ]; then
    echo "[X] Error: A directory named '$TARGET_DIR' already exists."
    exit 1
fi

mkdir -p "$TARGET_DIR/Helpers" "$TARGET_DIR/reports" || { echo "[X] Error: Write permissions denied."; exit 1; }
echo "[+] Structure mapped: /Helpers and /reports directories created successfully."

# --- 3. INJECT SOURCE CODE FILES ---
echo -e "\n[*] Populating application source assets..."

cat << 'INNER_EOF' > "$TARGET_DIR/attendance_checker.py"
import csv
import json
import os
from datetime import datetime

def run_attendance_check():
    with open('Helpers/config.json', 'r') as f:
        config = json.load(f)
    if os.path.exists('reports/reports.log'):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        os.rename('reports/reports.log', f'reports/reports_{timestamp}.log.archive')
    with open('Helpers/assets.csv', mode='r') as f, open('reports/reports.log', 'w') as log:
        reader = csv.DictReader(f)
        total_sessions = config['total_sessions']
        log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")
        for row in reader:
            name = row['Names']
            email = row['Email']
            attended = int(row['Attendance Count'])
            attendance_pct = (attended / total_sessions) * 100
            message = ""
            if attendance_pct < config['thresholds']['failure']:
                message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}%. You will fail this class."
            elif attendance_pct < config['thresholds']['warning']:
                message = f"WARNING: {name}, your attendance is {attendance_pct:.1f}%. Please be careful."
            if message:
                if config['run_mode'] == "live":
                    log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}\n")
                    print(f"Logged alert for {name}")
                else:
                    print(f"[DRY RUN] Email to {email}: {message}")

if __name__ == "__main__":
    run_attendance_check()
INNER_EOF

cat << 'INNER_EOF' > "$TARGET_DIR/Helpers/assets.csv"
Email,Names,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0
INNER_EOF

cat << 'INNER_EOF' > "$TARGET_DIR/Helpers/config.json"
{
    "thresholds": {
        "warning": 75,
        "failure": 50
    },
    "run_mode": "live",
    "total_sessions": 15
}
INNER_EOF
printf -- "---\nAttendance Report Run: $(date '+%Y-%m-%d %H:%M:%S.%N') ---\n[$(date '+%Y-%m-%d %H:%M:%S.%N')] ALERT SENT TO bob@example.com: URGENT: Bob Smith, your attendance is 46.7%%.\nYou will fail this class.\n[$(date '+%Y-%m-%d %H:%M:%S.%N')] ALERT SENT TO charlie@example.com: URGENT: Charlie Davis, your attendance is 26.7%%.\nYou will fail this class.\n" > "$TARGET_DIR/reports/reports.log"
echo "[+] Source file arrays deployed successfully."

# --- 4. DYNAMIC CONFIGURATION WITH USER VALIDATION (Config & Env Validation) ---
echo -e "\n[*] Initiating Dynamic Configuration..."
read -p "Do you want to update the default attendance thresholds? (y/N): " UPDATE_CHOICE

WARNING_VAL=75
FAILURE_VAL=50

if [[ "$UPDATE_CHOICE" =~ ^[Yy]$ ]]; then
    # Strict numeric validation loop for Warning Threshold
    while true; do
        read -p "Enter Warning Threshold percentage (0-100) [Default 75]: " USER_WARN
        if [ -z "$USER_WARN" ]; then
            break
        elif [[ "$USER_WARN" =~ ^[0-9]+$ ]] && [ "$USER_WARN" -ge 0 ] && [ "$USER_WARN" -le 100 ]; then
            WARNING_VAL=$USER_WARN
            break
        else
            echo "[X] Invalid input. Please enter a valid number between 0 and 100."
        fi
    done

    # Strict numeric validation loop for Failure Threshold
    while true; do
        read -p "Enter Failure Threshold percentage (0-100) [Default 50]: " USER_FAIL
        if [ -z "$USER_FAIL" ]; then
            break
        elif [[ "$USER_FAIL" =~ ^[0-9]+$ ]] && [ "$USER_FAIL" -ge 0 ] && [ "$USER_FAIL" -le 100 ]; then
            FAILURE_VAL=$USER_FAIL
            break
        else
            echo "[X] Invalid input. Please enter a valid number between 0 and 100."
        fi
    done

    # In-place stream editing manipulation
    sed -i.bak -E "s/(\"warning\": *)[0-9]+/\1$WARNING_VAL/" "$TARGET_DIR/Helpers/config.json"
    sed -i.bak -E "s/(\"failure\": *)[0-9]+/\1$FAILURE_VAL/" "$TARGET_DIR/Helpers/config.json"
    rm -f "$TARGET_DIR/Helpers/config.json.bak"
    echo "[+] Configuration successfully updated -> Warning: ${WARNING_VAL}%, Failure: ${FAILURE_VAL}%"
else
    echo "[*] Skipping customization. Retaining standard system defaults."
fi

# --- 5. ENVIRONMENT VALIDATION (Health Check) ---
echo -e "\n[*] Running System Environment Health Check..."
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version)
    echo "[SUCCESS] Environment validation passed: $PYTHON_VERSION"
else
    echo "[WARNING] System Core Alert: 'python3' was not detected on this system architecture."
fi

echo -e "\n===================================================="
echo "[🎉] BOOTSTRAPPING COMPLETE!"
echo "===================================================="
echo -e "====================================================================\nSTUDENT ATTENDANCE TRACKER - AUTOMATED ENVIRONMENT LOG SYSTEM\n====================================================================\n[$(date '+%Y-%m-%d %H:%M:%S')] SYSTEM: Workspace environment successfully bootstrapped.\n[$(date '+%Y-%m-%d %H:%M:%S')] STATUS: Logging channel initialized and armed.\n====================================================================" > "${parent_dir}/reports/reports.log"
