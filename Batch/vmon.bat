@echo off & setlocal enabledelayedexpansion
echo "Start Hadoop Cluster..."
vmrun -T ws start "C:\vmware\hadoop101\hadoop101.vmx" nogui
vmrun -T ws start "C:\vmware\hadoop102\hadoop102.vmx" nogui
vmrun -T ws start "C:\vmware\hadoop103\hadoop103.vmx" nogui