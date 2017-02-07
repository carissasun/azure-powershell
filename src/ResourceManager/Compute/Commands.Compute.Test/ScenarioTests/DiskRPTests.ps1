﻿# ----------------------------------------------------------------------------------
#
# Copyright Microsoft Corporation
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ----------------------------------------------------------------------------------

<#
.SYNOPSIS
Testing disk and snapshot commands
#>
function Test-Disk
{
    # Setup
    $rgname = Get-ComputeTestResourceName;
	$diskname = 'disk' + $rgname;

    try
    {
        # Common
        $loc = Get-ComputeVMLocation;
        New-AzureRmResourceGroup -Name $rgname -Location $loc -Force;
		$subId = Get-SubscriptionIdFromResourceGroup $rgname;
		$mocksourcevault = 'https://myvault.vault-int.azure-int.net/secrets/123/';
		$mockkey = '/subscriptions/' + $subId + '/resourceGroups/' + $rgname + '/providers/Microsoft.KeyVault/vaults/TestVault123';
		$access = 'Read';

        # Config create test
		$diskconfig = New-AzureRmDiskConfig -Location $loc -DiskSizeGB 5 -AccountType StandardLRS -OsType Windows -CreateOption Empty -EncryptionSettingsEnabled $true;
		# Encryption test
		$diskconfig = Set-AzureRmDiskDiskEncryptionKey -Disk $diskconfig -SecretUrl $mockkey -SourceVaultId $mocksourcevault;
		$diskconfig = Set-AzureRmDiskKeyEncryptionKey -Disk $diskconfig -KeyUrl $mockkey;
		$diskconfig.EncryptionSettings.Enabled = $false;
		$diskconfig.EncryptionSettings.DiskEncryptionKey = $null;
		$diskconfig.EncryptionSettings.KeyEncryptionKey = $null;
		New-AzureRmDisk -ResourceGroupName $rgname -DiskName $diskname -Disk $diskconfig;
		
		# Get disk test
		Get-AzureRmDisk -ResourceGroupName $rgname -DiskName $diskname;

		# Grant access test
		Grant-AzureRmDiskAccess -ResourceGroupName $rgname -DiskName $diskname -Access $access -DurationInSecond 5;
		Revoke-AzureRmDiskAccess -ResourceGroupName $rgname -DiskName $diskname;

		 #Config update test
		$updateconfig = New-AzureRmDiskConfig -Location $loc;
		$updateconfig = New-AzureRmDiskUpdateConfig -DiskSizeGB 10 -AccountType PremiumLRS -OsType Windows -CreateOption Empty;
		Update-AzureRmDisk -ResourceGroupName $rgname -DiskName $diskname -DiskUpdate $updateconfig;
		
		# Remove test
		Remove-AzureRmDisk -ResourceGroupName $rgname -DiskName $diskname -Force;
    }
    finally
    {
        # Cleanup
        Clean-ResourceGroup $rgname
    }
}

function Test-Snapshot
{
    # Setup
    $rgname = Get-ComputeTestResourceName;
	$snapshotname = 'snapshot' + $rgname;

    try
    {
        # Common
        $loc = Get-ComputeVMLocation;
        New-AzureRmResourceGroup -Name $rgname -Location $loc -Force;
		$subId = Get-SubscriptionIdFromResourceGroup $rgname;
		$mocksourcevault = 'https://myvault.vault-int.azure-int.net/secrets/123/';
		$mockkey = '/subscriptions/' + $subId + '/resourceGroups/' + $rgname + '/providers/Microsoft.KeyVault/vaults/TestVault123';
		$access = 'Read';

        # Config and create test
		$snapshotconfig = New-AzureRmSnapshotConfig -Location $loc -DiskSizeGB 5 -AccountType StandardLRS -OsType Windows -CreateOption Empty -EncryptionSettingsEnabled $true;
		$snapshotconfig = Set-AzureRmSnapshotDiskEncryptionKey -Snapshot $snapshotconfig -SecretUrl $mockkey -SourceVaultId $mocksourcevault;
		$snapshotconfig = Set-AzureRmSnapshotKeyEncryptionKey -Snapshot $snapshotconfig -KeyUrl $mockkey;
		$snapshotconfig.EncryptionSettings.Enabled = $false;
		$snapshotconfig.EncryptionSettings.DiskEncryptionKey = $null;
		$snapshotconfig.EncryptionSettings.KeyEncryptionKey = $null;
		New-AzureRmSnapshot -ResourceGroupName $rgname -SnapshotName $snapshotname -Snapshot $snapshotconfig;

		# Get snapshot test
		Get-AzureRmSnapshot -ResourceGroupName $rgname -SnapshotName $snapshotname;

		# Grant access test
		Grant-AzureRmSnapshotAccess -ResourceGroupName $rgname -SnapshotName $snapshotname -Access $access -DurationInSecond 5;
		Revoke-AzureRmSnapshotAccess -ResourceGroupName $rgname -SnapshotName $snapshotname;

		# Config update test
		$updateconfig = New-AzureRmSnapshotConfig -Location $loc;
		$updateconfig = New-AzureRmSnapshotUpdateConfig -DiskSizeGB 10 -AccountType PremiumLRS -OsType Windows -CreateOption Empty;
		Update-AzureRmSnapshot -ResourceGroupName $rgname -SnapshotName $snapshotname -SnapshotUpdate $updateconfig;
		
		# Remove test
		Remove-AzureRmSnapshot -ResourceGroupName $rgname -SnapshotName $snapshotname -Force;
    }
    finally
    {
        # Cleanup
        Clean-ResourceGroup $rgname
    }
}