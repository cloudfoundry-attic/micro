#!/bin/sh

# Attempt to automatically start the Micro Cloud Foundry VM.

vmx_file=micro.vmx

tries=( \
    `which vmrun` \
    '/Applications/VMware Fusion.app/Contents/Library/vmrun' \
)

for try in "${tries[@]}"; do
    if [[ -x "$try" ]]; then
        "$try" start "$vmx_file"
        exit
    fi
done

echo 'Unable to find the vmrun command.'
echo "Please open $vmx_file in VMware Workstation, Player or Fusion."
exit 1
