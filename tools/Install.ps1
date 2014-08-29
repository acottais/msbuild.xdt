param($installPath, $toolsPath, $package, $project)

if ($project.Object.References.Item("Microsoft.Web.XmlTransform"))
{
$project.Object.References.Item("Microsoft.Web.XmlTransform").Remove()
}
