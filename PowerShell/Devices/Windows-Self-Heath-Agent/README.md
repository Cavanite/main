# 🖥️ Windows Computer Health Monitor

A **PowerShell-based Windows program** that allows users to monitor and manage their own computer health.  
It provides visibility into system status and enables simple maintenance tasks such as installing updates.  

---

## ✨ Features

- 🔄 **Windows Updates**
  - Check for missing updates
  - Gather and install updates directly

- ⚠️ **System Health**
  - Detect if a **pending reboot** is required
  - Identify missing **Windows Updates**
  - Check for **application updates** via [WinGet](https://learn.microsoft.com/en-us/windows/package-manager/winget/)

- 🏢 **Device Deployment State**
  - Shows whether the device is:
    - **Domain Joined**
    - **Entra ID Joined**
    - **Intune Managed**

---

## 🚀 Getting Started

### Prerequisites
- Windows 10/11  
- [PowerShell 5.1+](https://learn.microsoft.com/en-us/powershell/) or [PowerShell 7+](https://github.com/PowerShell/PowerShell)  
- [WinGet](https://learn.microsoft.com/en-us/windows/package-manager/winget/) (for application updates)  

### Installation
Clone this repository:
```powershell
git clone https://github.com/yourusername/your-repo-name.git
