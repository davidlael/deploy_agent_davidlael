cleanup_trap() {
    echo -e "\n\n[!] SIGINT (Ctrl+C) detected! Initiating emergency cleanup sequence..."
    if [ -d "$TARGET_DIR" ]; then
        echo "[*] Bundling partial project state into an archive..."
        ARCHIVE_NAME="attendance_tracker_${USER_INPUT}_archive"
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
echo "===================================================="
echo "    AUTOMATED ATTENDANCE TRACKER PROJECT FACTORY     "
echo "===================================================="

read -p "Enter a unique identifier for your tracker workspace: " USER_INPUT

if [ -z "$USER_INPUT" ]; then
    echo "[X] Error: Identifier cannot be empty. Terminating setup."
    exit 1
fi

TARGET_DIR="attendance_tracker_${USER_INPUT}"
echo -e "\n[*] Initializing directory architecture for: $TARGET_DIR..."

if [ -d "$TARGET_DIR" ]; then
    echo "[X] Error: A directory named '$TARGET_DIR' already exists."
    exit 1
fi

mkdir -p "$TARGET_DIR/Helpers" "$TARGET_DIR/reports"
echo "[+] Structure mapped: /Helpers and /reports directories created successfully."
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

touch "$TARGET_DIR/reports/reports.log"
echo "[+] Source file arrays deployed successfully."
echo -e "\n[*] Initiating Dynamic Configuration..."
read -p "Do you want to update the default attendance thresholds? (y/N): " UPDATE_CHOICE

WARNING_VAL=75
FAILURE_VAL=50

if [[ "$UPDATE_CHOICE" =~ ^[Yy]$ ]]; then
    read -p "Enter Warning Threshold percentage (Default 75): " USER_WARN
    if [ -n "$USER_WARN" ] && [[ "$USER_WARN" =~ ^[0-9]+$ ]]; then WARNING_VAL=$USER_WARN; fi
    read -p "Enter Failure Threshold percentage (Default 50): " USER_FAIL
    if [ -n "$USER_FAIL" ] && [[ "$USER_FAIL" =~ ^[0-9]+$ ]]; then FAILURE_VAL=$USER_FAIL; fi

    sed -i.bak -E "s/(\"warning\": *)[0-9]+/\1$WARNING_VAL/" "$TARGET_DIR/Helpers/config.json"
    sed -i.bak -E "s/(\"failure\": *)[0-9]+/\1$FAILURE_VAL/" "$TARGET_DIR/Helpers/config.json"
    rm -f "$TARGET_DIR/Helpers/config.json.bak"
fi
echo -e "\n[*] Running System Environment Health Check..."
if command -v python3 &> /dev/null; then
    python3 --version
fi
echo -e "\n===================================================="
echo "[🎉] BOOTSTRAPPING COMPLETE!"
echo "===================================================="
