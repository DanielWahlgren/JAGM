---
external help file: JAGM-help.xml
Module Name: JAGM
online version: @{Name=Pester; Version=5.5.0; Type=Module; Description=Pester provides a framework for running BDD style Tests to execute and validate PowerShell commands inside of PowerShell and offers a powerful set of Mocking Functions that allow tests to mimic and mock the functionality of any command inside of a piece of PowerShell code being tested. Pester tests can execute any command or script that is accessible to a pester test file. This can include functions, Cmdlets, Modules and scripts. Pester can be run in ad hoc style in a console or it can be integrated into the Build scripts of a Continuous Integration system.; Author=Pester Team; CompanyName=System.Object[]; Copyright=Copyright (c) 2021 by Pester Team, licensed under Apache 2.0 License.; PublishedDate=2023-06-27 16:09:16; InstalledDate=; UpdatedDate=; LicenseUri=https://www.apache.org/licenses/LICENSE-2.0.html; ProjectUri=https://github.com/Pester/Pester; IconUri=https://raw.githubusercontent.com/pester/Pester/main/images/pester.PNG; Tags=System.Object[]; Includes=System.Collections.Hashtable; PowerShellGetFormatVersion=; ReleaseNotes=https://github.com/pester/Pester/releases/tag/5.5.0; Dependencies=System.Object[]; RepositorySourceLocation=https://www.powershellgallery.com/api/v2; Repository=PSGallery; PackageManagementProvider=NuGet; AdditionalMetadata=}
schema: 2.0.0
---

# Test-JGUserPassword

## SYNOPSIS
Helper-function to check a user's password against the organization's password validation policy.

## SYNTAX

```
Test-JGUserPassword [[-Password] <SecureString>] [<CommonParameters>]
```

## DESCRIPTION
Helper-function to check a user's password against the organization's password validation policy and report whether the password is valid.
Currently only works on Beta, and only with Delegated permissions.

## EXAMPLES

### EXAMPLE 1
```
Test-JGUser -ObjectId $person1
Test if user exists
```

## PARAMETERS

### -Password
The passwordto verify against Graph.

```yaml
Type: SecureString
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None.
## OUTPUTS

### [System.Boolean].
## NOTES

## RELATED LINKS
