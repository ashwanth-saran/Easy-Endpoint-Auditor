🛡️ Easy Endpoint Auditor (EEA)
A lightweight, automated forensic triage tool for Windows systems.

📖 Overview
The Easy Endpoint Auditor is a simple but powerful security tool designed to give you visibility into your computer's health. Think of it as a "Security Camera" for your operating system. Every time your computer starts, it takes a digital snapshot of critical areas and saves the details into a text file for you to review.

🧐 What does it actually monitor?
It focuses on the four most common "footprints" left behind by hackers or malware:

The Guest List (Persistence): Identifies programs set to start automatically (where malware hides to survive a reboot).

The Phone Calls (Network): Lists active connections to the internet to spot "Command & Control" communication.

The Hiding Spots (Folders): Flags any software running from "Temp" or "AppData" folders—common hiding spots for viruses.

The Lock-Picker (Security Logs): Scans for failed password attempts to detect if someone is trying to brute-force your account.

🚀 Getting Started (Step-by-Step)
1. Prepare the Folders
Open File Explorer and go to C:\Users\Public.

Create a new folder named SOC_Tools.

Inside SOC_Tools, create another folder named SOC_Logs.

2. Save the Script
Copy the provided PowerShell code.

Open Notepad, paste the code, and save the file as AnalyzeEndpoint.ps1.

Move this file into your C:\Users\Public\SOC_Tools\ folder.

3. Automate the Audit
To make the auditor run silently in the background every time you turn on your PC:

Right-click the Start button and select Terminal (Admin) or PowerShell (Admin).

Paste the following command and press Enter:

PowerShell
schtasks /create /tn "SOC_Audit" /tr "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File C:\Users\Public\SOC_Tools\AnalyzeEndpoint.ps1" /sc ONSTART /rl HIGHEST /f
📂 Accessing Your Reports
Your security reports are stored here:

C:\Users\Public\SOC_Tools\SOC_Logs\

How to Read the Results:
Open the latest .txt file. Look for these "Red Flags":

Failed Logons: If this number is high (e.g., >50), someone may be trying to crack your password.

Network: Look for processes like powershell.exe or cmd.exe talking to unknown IP addresses.

Paths: Any process running from a \Temp\ folder should be treated as suspicious.

🛠️ System Requirements
OS: Windows 10 or Windows 11.

Privileges: Must be installed using Administrator rights (required to read protected security logs).

Security Policy: The command uses -ExecutionPolicy Bypass to allow the script to run without changing your system-wide security settings.

📝 Disclaimer
This tool is for educational and authorized security monitoring purposes only. Using this tool to monitor a system without permission is strictly prohibited.

---
## 👤 Author
**[Ashwanth saran jc]**
* SOC Analyst 
* [https://www.linkedin.com/in/ashwanthsaran08]
* [https://ashufoilo.netlify.app/]

---
