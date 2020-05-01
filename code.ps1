Param(
     # Parameters that contains the input value provided by the user from Azure Automation.

     # Used by us to know which virtual machine to start/stop.
     [string]$VmName,
     # Used by us to know which virtual machine to start/stop within a resource group.
     [string]$ResourceGroupName,
     # Used by us to know which what to do (ie to start or to stop)
     [ValidateSet("Start", "Stop")]
     [string]$VmAction
)
 
    # Being able to run it through Azure Automation.
    $connectionName = "AzureRunAsConnection"
    try
    {
        # Get the connection "AzureRunAsConnection"
        $servicePrincipalConnection = Get-AutomationConnection -Name $connectionName         

        "Logging in to Azure..."
        Add-AzureRmAccount `
            -ServicePrincipal `
            -TenantId $servicePrincipalConnection.TenantId `
            -ApplicationId $servicePrincipalConnection.ApplicationId `
            -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint > $null
    } catch {
        if (!$servicePrincipalConnection)
        {
            $ErrorMessage = "Connection $connectionName not found."
            throw $ErrorMessage
        } else {
            Write-Error -Message $_.Exception
            throw $_.Exception
        }
    }

# Get current date
$UTCTime = (Get-Date).ToUniversalTime()
$TZ = [System.TimeZoneInfo]::FindSystemTimeZoneById("Central Europe Standard Time")
$LocalTime = [System.TimeZoneInfo]::ConvertTimeFromUtc($UTCTime, $TZ)
$day = $LocalTime.DayOfWeek

# Validate whether this is running on a weekend
# if you wish to use different days you can use any of the following:
# Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday
if ($day -eq 'Saturday' -or $day -eq 'Sunday')
{
    Write-Output ("It is $($day). Cannot use a runbook to start VMs on a weekend.")
    Exit
} else {
    Write-Output ("✔️ It is $($day). Continuing...")

    # Start 
    if ($VmAction -eq "Start") {
        # If input is wildcard, then start all virtual machines within resource group
        if($VmName -eq "*") {
            $vms = Get-AzureRmVM -ResourceGroupName $ResourceGroupName | Select Name
            Foreach ( $vm in $vms )
            {
                Write-Output ("🔌 Starting $($vm.Name) on resource group $($ResourceGroupName)...")
                Start-AzureRmVM -Name $vm.Name -ResourceGroupName $ResourceGroupName > $null
                $state = Get-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $vm.Name -Status > $null

                if($state.Statuses[1].Code -eq "PowerState/running")
                {
                    Write-Output ("✔️ Successfully started $($vm.Name), it is now running.")
                } else {
                    Write-Output ("❌ Unable to start $($vm.Name), current status: $($state.Statuses[1].Code).")
                } 
            }
        } else {
        # If not, just start the specific one
            Write-Output ("🔌 Starting $($VmName) on resource group $($ResourceGroupName)...")
            Start-AzureRmVM -Name $VmName -ResourceGroupName $ResourceGroupName
            $state = Get-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $VmName -Status > $null

            if($state.Statuses[1].Code -eq "PowerState/running")
            {
                Write-Output ("✔️ Successfully started $($VmName), it is now running.")
            } else {
                Write-Output ("❌ Unable to start $($VmName), current status: $($state.Statuses[1].Code).")
            }
        }
    }
 
    # Stop
    if ($VmAction -eq "Stop") {
        # If input is wildcard, then stop all virtual machines within resource group
        if($VmName -eq "*") {
            $vms = Get-AzureRmVM -ResourceGroupName $ResourceGroupName | Select Name
            Foreach ( $vm in $vms )
            {
                Write-Output ("🔌 Stopping $($vm.Name) on resource group $($ResourceGroupName)...")
                Stop-AzureRmVM -Name $vm.Name -ResourceGroupName $ResourceGroupName -Force
                $state = Get-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $vm.Name -Status > $null

                if($state.Statuses[1].Code -eq "PowerState/deallocated")
                {
                    Write-Output ("✔️ Successfully stopped $($vm.Name), it is now deallocated.")
                } else {
                    Write-Output ("❌ Unable to stop $($vm.Name), current status: $($state.Statuses[1].Code).")
                } 
            }
        } else {
        # If not, just stop the specific one
            Write-Output ("🔌 Stopping $($VmName) on resource group $($ResourceGroupName)...")
            Stop-AzureRmVM -Name $VmName -ResourceGroupName $ResourceGroupName -Force
            $state = Get-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $VmName -Status > $null

            if($state.Statuses[1].Code -eq "PowerState/deallocated")
            {
                Write-Output ("✔️ Successfully stopped $($VmName), it is now deallocated.")
            } else {
                Write-Output ("❌ Unable to stop $($VmName), current status: $($state.Statuses[1].Code).")
            }
        }
    }
}