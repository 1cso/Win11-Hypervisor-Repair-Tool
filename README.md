# Win11-Hypervisor-Repair-Tool

**Version:** 1.1  
**Supported OS:** Windows 10 / Windows 11

Advanced command-line utility for diagnosing and repairing BSOD errors related to virtualization and hypervisor issues. The tool provides automated and manual repair options, diagnostics reports, and structured logging.

---

## Supported BSOD Errors

This tool targets the following hypervisor and virtualization-related blue screen errors:

- **HYPERVISOR_ERROR** – typically caused by hypervisor misconfiguration or driver conflicts.
- **HYPERVISOR_LAUNCH_FAILED** – often due to virtualization being disabled in BIOS or conflicting software.
- **CLOCK_WATCHDOG_TIMEOUT** – may occur if hypervisor timing or CPU virtualization is misconfigured.
- **SYSTEM_SERVICE_EXCEPTION** – when related to hypervisor drivers or virtualization stack issues.
- **KMODE_EXCEPTION_NOT_HANDLED** – specifically when caused by faulty hypervisor or virtualization drivers.

---

## Features

1. **Diagnostics and Analysis**
   - Checks hypervisor launch type.
   - Detects CPU virtualization support.
   - Reports Virtualization-Based Security (VBS) and Device Guard status.
   - Detects installed virtualization software (VMware, VirtualBox, WSL2, Docker Desktop).
   - Lists recent crash dumps for root cause investigation.
   - Generates a structured report (`system_report.txt`) with critical, warning, and informational messages.

2. **Repair Operations**
   - **Disable Hyper-V stack** (Microsoft Hyper-V, VirtualMachinePlatform, HypervisorPlatform).
   - **Enable/Repair system files** using `SFC /scannow` and `DISM /RestoreHealth`.
   - **CHKDSK** with `/f /r` on multiple drives.
   - **Disable VBS and HVCI** for compatibility with third-party hypervisors.
   - **Backup BCD** before making changes.

3. **Full Smart Repair**
   - Combines diagnostics, Hyper-V stack repair, system file repair, disk check, and VBS disable in one automated operation.
   - Supports **silent** and **dry-run** modes.

4. **Logging**
   - All operations are logged to `repair_log.txt` with timestamps.
   - Structured logging helps track each step and possible errors.

---

## Usage

### Basic Menu
Run the tool as administrator and follow the interactive menu:
Win11-Hypervisor-Repair-Tool.bat

**Menu options:**

1. **Diagnostics + Analysis**
2. **Create Restore Point**
3. **Disable Hyper-V stack**
4. **Repair system (SFC + DISM)**
5. **Full Smart Repair**
6. **Exit**

 

### Command-Line Options
- `/silent` – Runs full repair automatically without prompts.
- `/dry` – Dry-run mode; no changes are applied, only logs and report generated.

Example:
```bat
Win11-Hypervisor-Repair-Tool.bat /silent
Win11-Hypervisor-Repair-Tool.bat /dry
``` 


### Problem-Specific Solutions

| BSOD Error | Typical Cause | Recommended Action |
|------------|---------------|--------------------|
| HYPERVISOR_ERROR | Hyper-V misconfigured or conflicting software | Run Full Repair; ensure Hyper-V stack is consistent, disable conflicting VMs |
| HYPERVISOR_LAUNCH_FAILED | Virtualization disabled in BIOS, hypervisorlaunchtype off | Enable virtualization in BIOS, then run Full Repair |
| CLOCK_WATCHDOG_TIMEOUT | CPU timing issues | Run repair (SFC + DISM), check CPU virtualization status, disable conflicting hypervisors |
| SYSTEM_SERVICE_EXCEPTION | Faulty hypervisor drivers | Run Full Repair and disable VBS/HVCI if enabled |
| KMODE_EXCEPTION_NOT_HANDLED | Hypervisor driver issues | Disable Hyper-V stack, check VM software conflicts, update drivers |

---

## Recommendations Before Running

- Ensure you run the tool as administrator.
- Verify virtualization is enabled in BIOS/UEFI.
- Optionally create a Windows Restore Point or backup important data.
- Close other virtualization software (VMware, VirtualBox, WSL2, Docker Desktop).

---

## Output Files

- `repair_log.txt` – detailed step-by-step log of all operations.
- `system_report.txt` – full system diagnostics and analysis report.
- `bcd_backup.txt` – backup of current Boot Configuration Data.

---

## Notes

- The tool works on both Windows 10 and Windows 11.
- Disk checks (`chkdsk /f /r`) may require a reboot if files are locked.
- Dry-run mode is useful for testing without making any system changes.
- Silent mode is recommended for automated repairs in scripts or deployment environments.

---

## License
```
MIT License

Copyright (c) 2026 1cso

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
 
