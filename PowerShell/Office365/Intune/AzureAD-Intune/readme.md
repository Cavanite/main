# Intune Joined Guide by Cavanite

Welcome to the Intune Joined Guide by Cavanite! This guide is designed to assist you in joining Intune when your device is already joined to Azure AD using a business standard license. 

## Table of Contents

- [Introduction](#introduction)
- [Installation](#installation)
- [Usage](#usage)

## Introduction

In today's modern workplace, managing and securing devices is crucial. Microsoft Intune is a powerful tool for managing and securing devices, and many organizations use it to control and protect their resources. If your organization uses Azure AD with business standard licenses and you need to join Intune, this guide can help you navigate the process.
The XML will create a task in taskmanager which let the device re-register to Intune MDM. 

## Installation

This section should provide instructions on how to install and set up any necessary software or tools to use this guide effectively. If there are prerequisites, list them here.

## Usage

In this section, provide step-by-step instructions and explanations on how to use this guide effectively. You can break it down into smaller sub-sections if necessary. Include screenshots or code snippets if they enhance the understanding of the process.

1. **Prerequisites**: List any prerequisites that users should have in place before starting the Intune joining process.
Make sure you have Intune MDM enabled in your tenant.
Make sure the user has a Business Premium license assigned.

2. **Step 1: [Getting Ready]**: Describe the first step of joining Intune in detail. Include any commands, settings, or configurations that need to be performed.
Upload the script into N-Able RMM Script Manager, make sure its a manual task.
Change or Upgrade the Office365 license of the user.
Run the script and wait 20 minutes.

3. **Step 2: [Check the progress]**: Continue with the subsequent steps until the process is complete.
Refresh Intune Windows Devices, the device will pop-up eventually.

4. **Troubleshooting**: If there are common issues users might encounter during the process, provide troubleshooting tips and solutions.
The user doesn't pop-up? Check the user license.
Check of the laptop is offline.