#!/bin/bash
# workspace is typically "target" and must contain the files to package in the installer including the setup script
workspace="${1}"
projectVersion="${2}"
# installer name
projectNameVersion=`basename "${workspace}"`
# where to save the installer (parent of directory containing files)
targetDir=`dirname "${workspace}"`

# check for the makeself tool
#makezip=`which zip`
#if [ -z "$makezip" ]; then
#    echo "Missing zip tool"
#    exit 1
#fi

# unzip the openstack-extension components zip 
cd $targetDir/${projectNameVersion}
mkdir repository
policyagenthooksZip=$(ls mtwilson-openstack-node-policyagent-hooks-*.zip 2>/dev/null | head -1)
vmattestationZip=$(ls mtwilson-openstack-node-vm-attestation-*.zip 2>/dev/null | head -1)
echo "------------------------------------------------------------------------------"
echo $policyagenthooksZip
#echo $vmattestationZip
unzip ${policyagenthooksZip}
unzip ${vmattestationZip}
mv mtwilson-openstack-policyagent-hooks/ repository/
mv mtwilson-openstack-vm-attestation/ repository/
# Run makensis to generate the openstack-exttension windows installer
MAKENSIS=`which makensis`
if [ -z "$MAKENSIS" ]; then
    echo "Missing makensis tool"
    exit 1
fi

cd $targetDir
"$MAKENSIS" "${projectNameVersion}/openstackextinstallscript.nsi"
mv "${projectNameVersion}/Installer.exe" "${projectNameVersion}.exe"


