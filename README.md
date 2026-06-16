# Automated Project Bootstrapping & Process Management Framework

An enterprise-grade Infrastructure as Code (IaC) shell solution designed to automate the rapid generation, deployment, and validation of isolated workspace environments for a **Student Attendance Tracker** application.

---

## 💡 The Problem & The Solution

* **The Problem:** Setting up software workspaces manually introduces immense operational risks. Variations in folder configurations, unvalidated parameters, missing software dependencies, and orphaned directories from aborted tasks result in broken pipelines and lost engineering time.
* **The Solution:** This project replaces manual actions with an automated controller script (`setup_project.sh`). In under two seconds, it builds an immaculate workspace, runs automated host system diagnostics, rewrites configuration state dynamically, and cleans up after itself safely if interrupted.

---

## 🏗️ System Architecture & Folder Layout

When executed successfully, the script instantiates a strict directory topology layout to isolate code logic, data states, and evaluation outputs:

```text
deploy_agent_davidlael/
├── setup_project.sh         # The main automation infrastructure engine
├── README.md                # Comprehensive system documentation
└── attendance_tracker_{ID}/ # Dynamically generated user workspace
    ├── attendance_checker.py # Seeded Python application core file
    ├── Helpers/             # Data and parameter management layer
    │   ├── assets.csv       # Seeded database containing student records
    │   └── config.json      # Dynamic target metrics for system alert runs
    └── reports/             # Execution logs and monitoring output
        └── reports.log      # Output logging streams with real-time timestamps

---

## 📹 Project Walkthrough Video

Click the link below to watch the full 5-minute technical demonstration and code logic walkthrough:

👉 **[Watch the Student Attendance Tracker Walkthrough Video]( https://drive.google.com/file/d/1UTaRICbDHoQG61Ln6NkqnLu4Gfh7HfLQ/view?usp=sharing)**
