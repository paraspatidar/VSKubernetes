﻿$ErrorActionPreference = "Stop"

Import-Module $PSScriptRoot\Utils.psm1

$ENV:HOME = $ENV:USERPROFILE

if (.\minikube.exe status  | select-string "Running") {
    Exec { .\minikube.exe delete }
}

Exec { .\minikube.exe start --vm-driver=hyperv --hyperv-virtual-switch="$(GetVMSwitchName)" --cpus=4 --memory=4096 --disk-size=20g }
Exec { .\helm.exe init }
Exec { .\minikube.exe addons enable ingress }
Exec { .\minikube addons enable registry }
Exec { .\minikube addons enable heapster }

# Wait for tiller to become ready
Retry { .\helm.exe list 2>&1 | Out-Null }

if (-not (Test-Path "~\.draft")) {
    Exec { .\draft.exe init }
}

Write-Output "Done!"
