$OPENSTACK_EXT_REPOSITORY="C:\Program Files (x86)\Intel\Openstack-Extensions\repository"
$PATCH_UTILS="C:\Program Files (x86)\Intel\Openstack-Extensions\bin\patch-util-win.cmd"
$log_file="C:\Program Files (x86)\Intel\Openstack-Extensions\logs\patchInstallLog.txt"
$seperator="\"
$components = @(
    "mtwilson-openstack-policyagent-hooks";
    "mtwilson-openstack-vm-attestation";
)

Function getDistributionLocation
{
	return (python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")
}

Function getOpenstackVersion
{
	return "nt_" + (python -c "from nova import version; print version.version_string()")
}

Function findPatchDir ($component, $version)
{
	$major = $version.Split(".")[0]
	$minor = $version.Split(".")[1]
	$patch = $version.Split(".")[2]
	$path = $OPENSTACK_EXT_REPOSITORY + $seperator + $component + $seperator + $version
	$patch_dir = "'" + $path + "'"
	if ( Test-Path $patch_dir | Out-String ) 
	{
		return $path
	}
	Else
	{
		throw [System.IO.FileNotFoundException] "$patch_dir not found." 
	}
}

$distribution_location = getDistributionLocation 

$openstack_version = getOpenstackVersion

foreach ($component in $components)
{
	$patch_dir = findPatchDir $component $openstack_version 
	$args = "apply_patch ""$distribution_location"" ""$patch_dir\distribution-location.patch"" 1"
	Try {
		$proc_apply = Start-Process $PATCH_UTILS $args -PassThru | Wait-Process
		if ($proc_apply.ExitCode -gt 0 ) {
			echo "$_ exited with status code $($proc_apply.ExitCode)" 
		}
	}
	Catch {
		echo "Failed"
		exit
	}
}

Try {
	$service_restart = Start-Process $PATCH_UTILS openstackrestart -PassThru | Wait-Process
	if ($service_restart.ExitCode -gt 0 ) {
        echo "$_ exited with status code $($service_restart.ExitCode)"
	}
}
Catch {
	echo "Failed"
	exit
}

