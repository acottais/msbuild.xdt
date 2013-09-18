param($installPath, $toolsPath, $package)

Import-Module (Join-Path $toolsPath "AppConfigTransform.psm1")

$env:AppConfigTransformToolsPath=$toolsPath

function Get-SolutionDir {
    if($dte.Solution -and $dte.Solution.IsOpen) {
        return Split-Path $dte.Solution.Properties.Item("Path").Value
    }
    else {
        throw "Solution not avaliable"
    }
}

function Copy-XdtAssembly {

	$solutionDir = Get-SolutionDir
	$tasksToolsPath = (Join-Path $solutionDir ".transform")
    $packagesPath = (Split-Path $installPath)

	if(!(Test-Path $tasksToolsPath)) {
		mkdir $tasksToolsPath | Out-Null
	}

	Write-Host "Copying transform target file to $tasksToolsPath"
	Copy-Item "$toolsPath\AppConfigTransform.targets" $tasksToolsPath -Force | Out-Null
	Copy-Item "$toolsPath\Microsoft.Web.XmlTransform.dll" $tasksToolsPath -Force | Out-Null
    
	Write-Host "Don't forget to commit the .transform folder"

}