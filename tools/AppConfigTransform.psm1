
function Get-SolutionDir {
    if($dte.Solution -and $dte.Solution.IsOpen) {
        return Split-Path $dte.Solution.Properties.Item("Path").Value
    }
    else {
        throw "Solution not available"
    }
}

function Add-Transform {
    param(
        [parameter(ValueFromPipelineByPropertyName = $true,Mandatory=$false)]
        [string]$configurationName,
        [parameter(Mandatory=$false)]
        [string]$projectName
    )
   #Get the project
   if (!$projectName){
   $project=Get-Project
   }
   else {
   $project=Get-Project $projectName
   }
   
   #find the App.config
   try{
   $projectItem=$project.ProjectItems.Item("App.config");
 }
 catch 
 {
 Write-Error "An App.config file is required"
 return
 }
      
   if (!$configurationName)
   {
   $configurations=$project.ConfigurationManager.ConfigurationRowNames   
   }
   else 
   {
   $configurations=@($configurationName)
   }
   
   $templatePath = (Join-Path $env:AppConfigTransformToolsPath "App.template.config")   
  
   foreach($config in $configurations){
   #Add a new item to the project if no file already exist
   $itemPath=(Join-path  $project.Properties.Item("fullpath").Value "App.$config.config")
   if (!(Test-Path $itemPath)){
   $itemAdded=$projectItem.ProjectItems.AddFromTemplate($templatePath,"App.$config.config")
   Write-Host Added $itemAdded.Name to the project
   }
   else {
   Write-Error "App.$config.config already exist"
 }
   }
}


Export-ModuleMember Add-Transform