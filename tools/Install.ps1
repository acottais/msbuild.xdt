param($installPath, $toolsPath, $package, $project)

function Get-SolutionDir {
    if($dte.Solution -and $dte.Solution.IsOpen) {
        return Split-Path $dte.Solution.Properties.Item("Path").Value
    }
    else {
        throw "Solution not avaliable"
    }
}

function Copy-AnalysisFiles($project) {
	$solutionDir = Get-SolutionDir
	$tasksToolsPath = (Join-Path $solutionDir ".analysis")

	if(!(Test-Path $tasksToolsPath)) {
		mkdir $tasksToolsPath | Out-Null
	}

	Write-Host "Copying rules files to $tasksToolsPath"
	Copy-Item "$toolsPath\sonar.ruleset" $tasksToolsPath -Force | Out-Null
	Copy-Item "$toolsPath\sonar.StyleCop" $tasksToolsPath -Force | Out-Null

	Write-Host "Don't forget to commit the .analysis folder"
	return "$tasksToolsPath"
}

function Add-Solution-Folder($analysisPath) {
	# Get the open solution.
	$solution = Get-Interface $dte.Solution ([EnvDTE80.Solution2])

	# Create the solution folder.
	$analysisFolder = $solution.Projects | Where {$_.ProjectName -eq ".analysis"}
	if (!$analysisFolder) {
		$analysisFolder = $solution.AddSolutionFolder(".analysis")
	}

	
	# Add files to solution folder
	$projectItems = Get-Interface $analysisFolder.ProjectItems ([EnvDTE.ProjectItems])

	$targetsPath = [IO.Path]::GetFullPath( (Join-Path $analysisPath "sonar.ruleset") )
	$projectItems.AddFromFile($targetsPath)

	$dllPath = [IO.Path]::GetFullPath( (Join-Path $analysisPath "sonar.StyleCop") )
	$projectItems.AddFromFile($dllPath)

}

function Add-Constants ($constant) {
	"Adding {0} constants to Debug configuration" -f $constant | Write-Host
$project.ConfigurationManager | Where-Object { $_.ConfigurationName -eq "Debug"}  | ForEach-Object { 
    $defineConstants=$_.Properties.Item("DefineConstants").Value;
    if (!$defineConstants.Contains($constant)){
        $defineConstants+=";"+$constant;
    }
    $_.Properties.Item("DefineConstants").Value=$defineConstants;
}
}

function Set-CodeAnalysisRuleSet($analysisPath) {
$rulesetPath = [IO.Path]::GetFullPath( (Join-Path $analysisPath "sonar.ruleset") )
$project.ConfigurationManager | ForEach-Object { 
    $_.Properties.Item("CodeAnalysisRuleSet").Value=$rulesetPath;
    }
}

function Set-StyleCopLinkedFiles($analysisPath) {
$styleCopPath=[IO.Path]::GetFullPath( (Join-Path $analysisPath "sonar.StyleCop") )
$oldLocation=Get-Location
Set-Location $project.Properties.Item("LocalPath").Value
$relativePath=Resolve-Path $styleCopPath -Relative
Set-Location $oldLocation
$xmlContent=Get-Content $project.ProjectItems.Item("Settings.StyleCop").Properties.item("LocalPath").Value
$xDoc=new-Object xml.XmlDocument
$xDoc.LoadXml($xmlContent)
$elem=$xDoc.StyleCopSettings.GlobalSettings.StringProperty |Where-Object {$_.Name -eq "LinkedSettingsFile"}
$elem.innerText=$relativePath
$xDoc.Save($project.ProjectItems.Item("Settings.StyleCop").Properties.item("LocalPath").Value)
}

function Enable-RunCodeAnalysis {
{
	"Enabling RunCodeAnalysis property for debug configurations" | Write-Host
$project.ConfigurationManager | Where-Object { $_.ConfigurationName -eq "Debug"}  | ForEach-Object { 
    $_.Properties.Item("RunCodeAnalysis").Value="true";
}
}
}




function Main 
{
	$taskPath = Copy-AnalysisFiles $project
	Add-Solution-Folder $taskPath
    Add-Constants "CODE_ANALYSIS"
    Set-CodeAnalysisRuleSet $taskPath
    Enable-RunCodeAnalysis
    Set-StyleCopLinkedFiles $taskPath
    $project.Save()
}

Main
