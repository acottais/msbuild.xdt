AppConfigTransform
===========

A simple Nuget Package that enable App.Config Transformations based on the Microsoft.Web.Xdt engine, just like Web Applications projects.


### Installation

1. Install the package using the package manager console
```
Install-Package AppConfigTransform 
```
2. Manually Remove the reference to Microsoft.Web.Xdt on your project (added from the dependency of the package).

### Adding new transformation

The package adds one new powershell cmdlet "Add-Transform" that create a simple transformation file. to use it just type in the Package manager console
```
Add-Transform <configuration>
```
example:
```
Add-Transform Release
```
