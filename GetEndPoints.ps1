<#
 * Copyright Microsoft Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
#>

[CmdletBinding()]
Param(
    [parameter(Mandatory=$true)][string]$SubName
)

if((Get-AzureSubscription -SubscriptionName $SubName) -eq $null){
Write-Host "Invaild Subscription name";exit}

try {
Select-AzureSubscription -SubscriptionName $SubName -ErrorAction Stop
}catch{"$($SubName) is a valid Subscription, but remember subscription names are case sensitive";exit}

##Start overall stop watch
$oa_stopWatch = New-Object System.Diagnostics.Stopwatch;$oa_stopWatch.Start()
cls;Write-Host "`n`n"

Write-Host "Collecting VM(s) from subscription $($SubName)" -NoNewline
$VMs = Get-AzureVM | sort ServiceName
Write-Host " Found $($VMs.count) VM(s)`n"

foreach($VM in $VMs) 
{
   $endpoints = $vm | Get-AzureEndpoint
   if (![string]::IsNullOrEmpty($endpoints)) 
   {
         Write-Host ("{0} in {1} has {2} Public Endpoint(s)" -f $vm.name,$vm.ServiceName,$endpoints.count)
         $PubVMs ++
         $PubEndPts += $endpoints.count
         if ($vm.status -eq "ReadyRole") {$VMRunning ++}
   }
}
Write-Host ("`n{0} VM(s) have {1} Public Endpoint(s) {2} VM(s) are running" -f $PubVMs,$PubEndPts,$VMRunning)
$oa_stopWatch.Stop();$ts = $oa_stopWatch.Elapsed
write-host ("`nTotal process completed in {0} hours {1} minutes, {2} seconds`n" -f $ts.Hours, $ts.Minutes, $ts.Seconds)

#End of script