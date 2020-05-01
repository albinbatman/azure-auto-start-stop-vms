![](https://i.imgur.com/N6GqEC1.png)

# Azure: Auto start/stop VM

This template allows you to quickly set up an automatic schedule that starts and stops your virtual machine(s) in Azure, based solely on your own schedule and adaptation of the code. This code is based on starting and stopping the virtual machines on weekdays (Mon-Fri) and exclude the weekends (Sat-Sun).

## ⚠️ Before you continue reading...
Please review [Pricing - Automation | Microsoft Azure](https://azure.microsoft.com/en-us/pricing/details/automation/) because this script expects you to use Automation in Azure and is also solely developed for this purpose.

If you are looking for a different solution, please reconsider the following ones:

### Azure-CLI (Bash)
The Azure CLI allows you to create and manage your Azure resources on macOS, Linux, and Windows.
* [Start or Stop all VMs of a Resource Group in Azure - attosol.com](https://www.attosol.com/start-or-stop-all-vms-of-a-resource-group-in-azure/)
## ⚙️ Installation

1. Download (or copy + paste) *code.ps1* to your local computer.
2. Go to [Automation Accounts - Microsoft Azure](https://portal.azure.com/#blade/HubsExtension/BrowseResource/resourceType/Microsoft.Automation%2FAutomationAccounts) and create a new account or use an existing one.
3. Below **Process Automation**, press **Runbooks**.
   1. Press **Create a runbook**.
   2. Give it a name (ie. **StartStopVM-ExcludingWeekends**) and select *PowerShell* under **Runbook type**.
   3. Once inside your newly created runbook, press the **Edit**-button on the top menu & then paste the code in there then press **Save** & **Publish**.
4. Go to **Schedules** to create a new schedule. We need one to start the VM and one to stop the VM.
   1. Press **Schedule** and then **Create a new schedule**.
      1. Give it a name (ie. **Start YourVirtualMachineName**) and an appropriate description.
      2. Make it start from today or tomorrow and specify the time (ie. **7 AM** to start) and make it recurring on every week and select Mon-Fri (to exclude weekends).
      3. Press **Parameters and run settings** and specify the details. (VMACTION: **Start** = starts the VM, **Stop** = stops the VM)
   2. Create a new **schedule** (as you did in 4.i)
      1. Give it a name (ie. **Stop YourVirtualMachineName**) and an appropriate description.
      2. Make it start from today or tomorrow and specify the time (ie. **8 PM** to start) and make it recurring on every week and select Mon-Fri (to exclude weekends).
      3. Press **Parameters and run settings** and specify the details. (VMACTION: **Start** = starts the VM, **Stop** = stops the VM)

## 🏷️ Features
* Automatically starts or stops all or one specific virtual machine within a resource group
* After each start/stop, checks status of each virtual machine to ensure it is in the proper state
* Unicode characters to visually represent all states

## 💡 Ideas to implement
* Allow for more specified virtual machines to be entered in **VmName** to split into an array so the script can start/stop multiple machines instead of either *all* or *one*

#### 📚 Good-to-know
A collection of good-to-know things about this script.

##### 🔌 Starting or stopping all VMs in a resource group
To start or stop multiple virtual machines within a specified resource group, you may do the following:
1. When scheduling in your automation account you may specify the **VMNAME** with an asterisk (*) in order to select all the virtual machines within the specified resource group.

