<#
.Synopsis
	Build script (https://github.com/nightroman/Invoke-Build)

.Description
	TASKS AND REQUIREMENTS
	Init
		Create folder structure and needed basefiles
			- Docs
			- Output
			-- ModuleName
			-- Temp
			- Source
			-- Private
			-- Public
			-- ModuleName.psd1
			-Tests
			-- ModuleName.Tests.PS1
			-- Pester.json
			- .gitignore
			- README.md

		Verify needed modules are installed and up to date.
			- Pester
			- PSScriptAnalyzer
			- platyPS
			- PowerShellGet

	Test
		Run all tests in ./Tests/ and compare results with expected

	DebugBuild
		Build Module into ./Output/Temp/

	Build
		Build Module into ./Output/ModuleName/
		Build Docs

	Publish
		Publishing Module to PowerShell gallery

	Clean
		Remove all files from ./Output/Temp/
#>

param (
	[ValidateSet("Release", "debug")]$Configuration = "debug",
	[Parameter(Mandatory = $false)][String]$NugetAPIKey,
	[Parameter(Mandatory = $false)][String]$ModuleVersion,
	[Parameter(Mandatory = $false)][Switch]$ExportAlias
)

task Init {
	# Create folder structure and needed basefiles
	try {
		$Script:ModuleName = (Test-ModuleManifest -Path (Join-Path '.' 'Sources' '*.psd1')).Name
	} catch {
		$Script:ModuleName = Split-Path -Path (Get-Location) -Leaf
	}

	$directories = 'Docs', (Join-Path 'Output' 'Temp'), (Join-Path 'Output' $ModuleName), (Join-Path 'Source' 'Private'), (Join-Path 'Source' 'Public'), 'Tests'
	foreach ($directory in $directories) {
		if (-not (Test-Path $directory)) {
			New-Item -Name $directory -ItemType Directory | Out-Null
		}
	}

	$files = @()
	$files += @{
		Filename    = '.gitignore'
		FileContent = 'T3V0cHV0L3RlbXAq'
	}
	$files += @{
		Filename    = (Join-Path 'Tests' ($ModuleName + '.Tests.PS1'))
		FileContent = ''
	}
	$files += @{
		Filename    = (Join-Path 'Tests' 'Pester.json')
		FileContent = 'ew0KCSJSdW4iOiB7DQoJCSJQYXRoIjogIi5cXFRlc3RzXFwqLnBzMSINCgl9LA0KCSJUZXN0UmVzdWx0Ijogew0KCQkiRW5hYmxlZCI6IHRydWUsDQoJCSJPdXRwdXRGb3JtYXQiOiAiTlVuaXRYbWwiDQoJfQ0KfQ=='
	}
	$files += @{
		Filename    = 'README.md'
		FileContent = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($ModuleName))
	}

	foreach ($file in $files) {
		if (-not (Test-Path $file.FileName)) {
			$Object = [System.Convert]::FromBase64String($file.FileContent)
			[system.io.file]::WriteAllBytes($file.FileName, $object)
		}
	}

	# Module Manifest
	if (-not (Test-Path (Join-Path 'Source' ($ModuleName + '.psd1')))) {
		break
		New-ModuleManifest -Path (Join-Path 'Source' ($ModuleName + '.psd1')) -ModuleVersion "0.0.1" -Author "YourNameHere"
	}

	# Verify needed modules are installed and up to date.
	$Modules = 'PSScriptAnalyzer', 'Pester', 'platyPS', 'PowerShellGet'
	foreach ($Module in $Modules) {
		Write-Verbose -Message "Initializing Module $Module"
		$local = Get-Module -Name $Module -ListAvailable
		if (-Not $local) {
			Write-Warning "Module '$Module' is missing. Installing module now."
			Install-Module -Name $Module -Scope CurrentUser -Force
		} else {
			if ($local.Count -gt 1) {
				$local = $local | Sort-Object Version -Descending | Select-Object -First 1
			}
			$online = Find-Module -Name $Module -Repository PSGallery -ErrorAction Stop
			if ([version]$local.version -lt [version]$online.version) {
				Write-Warning "Module '$Module' is out of date. Updating module now."
				Update-Module -Name $Module -Scope CurrentUser -Force
			}
		}
	}
}

task Test {
	try {
		Write-Verbose -Message "Running PSScriptAnalyzer on Public functions"
		Invoke-ScriptAnalyzer (Join-Path '.' 'Source' 'Public') -Recurse
		Write-Verbose -Message "Running PSScriptAnalyzer on Private functions"
		Invoke-ScriptAnalyzer (Join-Path '.' 'Source' 'Private') -Recurse
	} catch {
		throw "Couldn't run Script Analyzer"
	}

	Write-Verbose -Message "Running Pester Tests"
	$files = Get-ChildItem (Join-Path '.' 'Source') -File -Recurse -Include *.ps1
	$pesterFile = Get-Content (Join-Path 'Tests' 'Pester.json') | ConvertFrom-Json
	$pesterFileConfig = @{}
	foreach ($property in $pesterFile.PSObject.Properties) {
    	$pesterFileConfig[$property.Name] = $property.Value
	}
	$pesterConfiguration = New-PesterConfiguration -Hashtable $pesterFileConfig

	# Enables CodeCoverage
	$pesterConfiguration.CodeCoverage.Enabled = $true
	$pesterConfiguration.CodeCoverage.Path = $files
	$Results = Invoke-Pester -Configuration:$pesterConfiguration
	if ($Results.FailedCount -gt 0) {
		throw "$($Results.FailedCount) Tests failed"
	}
}

task DebugBuild -if ($Configuration -eq "debug") {
	try {
		$Script:ModuleName = (Test-ModuleManifest -Path (Join-Path '.' 'Sources' '*.psd1')).Name
	} catch {
		$Script:ModuleName = Split-Path -Path (Get-Location) -Leaf
	}

	Write-Verbose -Message "Generating the Module Manifest for temp build and generating new Module File"
	try {
		$PSDFrom = Join-Path '.' 'Source' "$($ModuleName).psd1"
		$PSDTo = Join-Path '.' 'Output' 'Temp'
		$PSMTo = Join-Path '.' 'Output' 'Temp' "$($ModuleName).psm1"
		if(Test-Path $PSDTo){ Get-Childitem -Path $PSDTo | Remove-Item -Recurse -Confirm:$false }
		Copy-Item -Path $PSDFrom -Destination $PSDTo -Force
		New-Item -Path $PSMTo  -ItemType File -Force | Out-null 
	} catch {
		throw "Failed copying Module Manifest from: $PSDFrom to $PSDTo or Generating $PSMTo file."
	}

	Write-Verbose -Message "Updating Module Manifest with Public Functions"
	$publicFunctions = Get-ChildItem -Path (Join-Path '.' 'Source' 'Public') -Recurse -Filter "*.ps1"
	$privateFunctions = Get-ChildItem -Path (Join-Path '.' 'Source' 'Private') -Recurse -Filter "*.ps1"
	try {
		Write-Verbose -Message "Appending Public functions to the psm file"
		$functionsToExport = New-Object -TypeName System.Collections.ArrayList
		foreach ($function in $publicFunctions.Name) {
			write-Verbose -Message "Exporting function: $(($function.split('.')[0]).ToString())"
			$functionsToExport.Add(($function.split('.')[0]).ToString()) | Out-null 
		}
		Update-ModuleManifest -Path (Join-Path '.' 'Output' 'Temp' "$($ModuleName).psd1") -FunctionsToExport $functionsToExport
	} catch {
		throw "Failed updating Module manifest with public functions"
	}
	Write-Verbose -Message "Building the .psm1 file"
	Write-Verbose -Message "Appending Public Functions"
	Add-Content -Path $PSMTo -Value "### --- PUBLIC FUNCTIONS --- ###"
	foreach ($function in $publicFunctions) {
		try {
			Write-Verbose -Message "Updating the .psm1 file with function: $($function.Name)"
			$content = Get-Content -Path $function.FullName
			Add-Content -Path $PSMTo -Value "#Region - $($function.Name)"
			Add-Content -Path $PSMTo -Value $content
			if ($ExportAlias.IsPresent) {
				$AliasSwitch = $false
				$Sel = Select-String -Path $function.FullName -Pattern "CmdletBinding" -Context 0, 1
				$mylist = $Sel.ToString().Split([Environment]::NewLine)
				foreach ($s in $mylist) {
					if ($s -match "Alias") {
						$alias = (($s.split(":")[2]).split("(")[1]).split(")")[0]
						Write-Verbose -Message "Exporting Alias: $($alias) to Function: $($function.Name)"
						Add-Content -Path $PSMTo -Value "Export-ModuleMember -Function $(($function.Name.split('.')[0]).ToString()) -Alias $alias"
						$AliasSwitch = $true
					}
				}
				if ($AliasSwitch -eq $false) {
					Write-Verbose -Message "No alias was found in function: $($function.Name))"
					Add-Content -Path $PSMTo -Value "Export-ModuleMember -Function $(($function.Name.split('.')[0]).ToString())"
				}
			} else {
				Add-Content -Path $PSMTo -Value "Export-ModuleMember -Function $(($function.Name.split('.')[0]).ToString())"
			}
			Add-Content -Path $PSMTo -Value "#EndRegion - $($function.Name)"
		} catch {
			throw "Failed adding content to .psm1 for function: $($function.Name)"
		}
	}

	Write-Verbose -Message "Appending Private functions"
	Add-Content -Path $PSMTo -Value "### --- PRIVATE FUNCTIONS --- ###"
	foreach ($function in $privateFunctions) {
		try {
			Write-Verbose -Message "Updating the .psm1 file with function: $($function.Name)"
			$content = Get-Content -Path $function.FullName
			Add-Content -Path $PSMTo -Value "#Region - $($function.Name)"
			Add-Content -Path $PSMTo -Value $content
			Add-Content -Path $PSMTo -Value "#EndRegion - $($function.Name)"            
		} catch {
			throw "Failed adding content to .psm1 for function: $($function.Name)"
		}
	}
}

task Build -if($Configuration -eq "Release") {
	try {
		$Script:ModuleName = (Test-ModuleManifest -Path (Join-Path '.' 'Sources' '*.psd1')).Name
	} catch {
		$Script:ModuleName = Split-Path -Path (Get-Location) -Leaf
	}

	$publicFunctions = Get-ChildItem -Path (Join-Path '.' 'Source' 'Public') -Recurse -Filter "*.ps1"
	$privateFunctions = Get-ChildItem -Path (Join-Path '.' 'Source' 'Private') -Recurse -Filter "*.ps1"


	if (!($ModuleVersion)) {
		Write-Verbose -Message "No new ModuleVersion was provided, locating existing version from psd file."
		$oldModuleVersion = (Test-ModuleManifest -Path (Join-Path '.' 'Source' '*.psd1')).Version
		$totalFunctions = $publicFunctions.count + $privateFunctions.count
		$ModuleBuildNumber = $oldModuleVersion.Build + 1
		Write-Verbose -Message "Updating the Moduleversion"
		$Script:ModuleVersion = "$($oldModuleVersion.Major).$($totalFunctions).$($ModuleBuildNumber)"
		Write-Verbose "Mew ModuleVersion: $ModuleVersion"
		Update-ModuleManifest -Path (Join-Path '.' 'Source' "$($ModuleName).psd1") -ModuleVersion $ModuleVersion
	}

	Write-Verbose -Message "Generating the Module Manifest for Release-build and generating new Module File"
	try {
		$PSDFrom = Join-Path '.' 'Source' "$($ModuleName).psd1"
		$PSDTo = Join-Path '.' 'Output' $ModuleName
		$PSDMTo = Join-Path '.' 'Output' $ModuleName "$($ModuleName).psm1"
		if(Test-Path $PSDTo){ Get-Childitem -Path $PSDTo | Remove-Item -Recurse -Confirm:$false }
		Copy-Item -Path $PSDFrom -Destination $PSDTo
		New-Item -Path $PSDMTo  -ItemType File | Out-null 
	} catch {
		throw "Failed copying Module Manifest from: $PSDFrom to $PSDTo or Generating the new psm file."
	}

	Write-Verbose -Message "Updating Module Manifest with Public Functions"
	try {
		Write-Verbose -Message "Appending Public functions to the psm file"
		$functionsToExport = New-Object -TypeName System.Collections.ArrayList
		foreach ($function in $publicFunctions.Name) {
			write-Verbose -Message "Exporting function: $(($function.split('.')[0]).ToString())"
			$functionsToExport.Add(($function.split('.')[0]).ToString()) | Out-null 
		}
		Update-ModuleManifest -Path (Join-Path '.' 'Output' $ModuleName "$($ModuleName).psd1") -FunctionsToExport $functionsToExport
	} catch {
		throw "Failed updating Module manifest with public functions"
	}
	Write-Verbose -Message "Building the .psm1 file"
	Write-Verbose -Message "Appending Public Functions"
	Add-Content -Path $PSDMTo -Value "### --- PUBLIC FUNCTIONS --- ###"
	foreach ($function in $publicFunctions) {
		try {
			Write-Verbose -Message "Updating the .psm1 file with function: $($function.Name)"
			$content = Get-Content -Path $function.FullName
			Add-Content -Path $PSDMTo -Value "#Region - $($function.Name)"
			Add-Content -Path $PSDMTo -Value $content
			if ($ExportAlias.IsPresent) {
				$AliasSwitch = $false
				$Sel = Select-String -Path $function.FullName -Pattern "CmdletBinding" -Context 0, 1
				$mylist = $Sel.ToString().Split([Environment]::NewLine)
				foreach ($s in $mylist) {
					if ($s -match "Alias") {
						$alias = (($s.split(":")[2]).split("(")[1]).split(")")[0]
						Write-Verbose -Message "Exporting Alias: $($alias) to Function: $($function.Name)"
						Add-Content -Path $PSDMTo -Value "Export-ModuleMember -Function $(($function.Name.split('.')[0]).ToString()) -Alias $alias"
						$AliasSwitch = $true
					}
				}
				if ($AliasSwitch -eq $false) {
					Write-Verbose -Message "No alias was found in function: $($function.Name))"
					Add-Content -Path $PSDMTo -Value "Export-ModuleMember -Function $(($function.Name.split('.')[0]).ToString())"
				}
			} else {
				Add-Content -Path $PSDMTo -Value "Export-ModuleMember -Function $(($function.Name.split('.')[0]).ToString())"
			}
			Add-Content -Path $PSDMTo -Value "#EndRegion - $($function.Name)"
		} catch {
			throw "Failed adding content to .psm1 for function: $($function.Name)"
		}
	}

	Write-Verbose -Message "Appending Private functions"
	Add-Content -Path $PSDMTo -Value "### --- PRIVATE FUNCTIONS --- ###"
	foreach ($function in $privateFunctions) {
		try {
			Write-Verbose -Message "Updating the .psm1 file with function: $($function.Name)"
			$content = Get-Content -Path $function.FullName
			Add-Content -Path $PSDMTo -Value "#Region - $($function.Name)"
			Add-Content -Path $PSDMTo -Value $content
			Add-Content -Path $PSDMTo -Value "#EndRegion - $($function.Name)"            
		} catch {
			throw "Failed adding content to .psm1 for function: $($function.Name)"
		}
	}

	Write-Verbose -Message "Updating Module Manifest with root module"
	try {
		Write-Verbose -Message "Updating the Module Manifest"
		Update-ModuleManifest -Path (Join-Path '.' 'Output' $ModuleName "$($ModuleName).psd1") -RootModule "$($ModuleName).psm1"
	} catch {
		Write-Warning -Message "Failed appinding the rootmodule to the Module Manifest"
	}

	Write-Verbose -Message "Compiling Help files"
	Write-Verbose -Message "Importing the module to be able to output documentation"
	Try {
		Write-Verbose -Message "Importing the module to be able to output documentation"
		Import-Module (Join-path '.' 'Output' $ModuleName "$($ModuleName).psm1")
	} catch {
		throw "Failed importing the module: $($ModuleName)"
	}

	if (!(Get-ChildItem -Path (Join-Path '.' 'Docs'))) {
		Write-Verbose -Message "Docs folder is empty, generating new files"
		if (Get-Module -Name $($ModuleName)) {
			Write-Verbose -Message "Module: $($ModuleName) is imported into session, generating Help Files"
			New-MarkdownHelp -Module $ModuleName -OutputFolder (Join-Path '.' 'Docs')
			New-MarkdownAboutHelp -OutputFolder (Join-Path '.' 'Docs') -AboutName $ModuleName
			New-ExternalHelp (Join-Path '.' 'Docs') -OutputPath (Join-Path '.' 'Output' $ModuleName 'en-US')
		} else {
			throw "Module is not imported, cannot generate help files"
		}
	} else {
		Write-Verbose -Message "Updating Help-files files."
		if (Get-Module -Name $($ModuleName)) {
			Write-Verbose -Message "Module: $($ModuleName) is imported into session, generating Help Files"
			Update-MarkdownHelpModule -Path (Join-Path '.' 'Docs')
			New-ExternalHelp (Join-Path '.' 'Docs') -OutputPath (Join-Path '.' 'Output' $ModuleName 'en-US')
		}
	}
}

task Publish -if($Configuration -eq "Release") {

	if(-not [String]::IsNullOrEmpty($NugetAPIKey)){
		$PSDMTo = Join-Path '.' 'Output' $ModuleName "$($ModuleName).psm1"
		Write-Verbose -Message "Publishing Module to PowerShell gallery"
		Write-Verbose -Message "Importing Module $PSDMTo"
		Import-Module $PSDMTo
		If ((Get-Module -Name $ModuleName) -and ($NugetAPIKey)) {
			try {
				write-Verbose -Message "Publishing Module: $($ModuleName)"
				Publish-Module -Name $ModuleName -NuGetApiKey $NugetAPIKey
			} catch {
				throw "Failed publishing module to PowerShell Gallery"
			}
		} else {
			Write-Warning -Message "Something went wrong, couldn't publish module to PSGallery. Did you provide a NugetKey?."
		}
	}
}

# Default task
task . Init, Test, DebugBuild