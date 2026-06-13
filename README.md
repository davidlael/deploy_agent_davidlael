# Automated Project Bootstrapping & Process Management Factory

This repository contains an automated environment initialization infrastructure designed to systematically deploy the workspace configuration for a Student Attendance Tracker application.

## Deployment and Usage Guide

### How to Run the Script
To bootstrap a new Student Attendance Tracker workspace environment, execute the master deployment script from the root directory using your bash runtime interpreter:
```bash
./setup_project.sh

```

### How to Trigger the Archive Feature (Signal Trap Testing)
The deployment controller features a built-in process management signal trap designed to handle unexpected execution termination gracefully (`SIGINT`). 

To trigger and verify this automated archival cleanup mechanism:
1. Initialize the script by running `./setup_project.sh`.
2. While the execution process is halted at an interactive user prompt (such as the workspace identifier input or the threshold override choice), issue a manual interrupt command from your keyboard by pressing **`Ctrl + C`**.
3. The script will catch the signal, prevent a dirty crash, and run the emergency sequence:
   * It bundles all initialized directory structures into a compressed backup asset named `attendance_tracker_{input}_archive.tar.gz`.
   * It runs a recursive cleanup (`rm -rf`) to completely scrub the partial workspace directory from your system to maintain an immaculate environment.
