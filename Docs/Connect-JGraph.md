---
external help file: JAGM-help.xml
Module Name: JAGM
online version:
schema: 2.0.0
---

# Connect-JGraph

## SYNOPSIS
Helper-function to connect to Microsoft Graph using a configuration from $PROFILE.

## SYNTAX

```
Connect-JGraph [[-TenantId] <String>] [[-Configuration] <Object>] [<CommonParameters>]
```

## DESCRIPTION
Helper-function to connect to Microsoft Graph using a configuration from the loaded profile.
See Get-Help about_profiles for more information about the location and syntax of the different profiles avaliable in PowerShell.
The Configuration will be used as-is, so for options, use Get-Help Connect-MgGraph

## EXAMPLES

### EXAMPLE 1
```
Connect-JGraph -TenantName:'contoso.onmicrosoft.com'
Connect to the Contoso-tenant using the configuration found in the loaded profile.
```

### EXAMPLE 2
```
Connect-EvtGraph -TenantName:'contoso.onmicrosoft.com' -AppContext:'MEM'
Connect to the Contoso-tenant using the ClientId and CertificateName for MEM (Microsoft Endpoint Manager - Eventful Modern Workspace)
```

## PARAMETERS

### -TenantId
The TenantId to use to connect to Microsoft Graph.
The TenantId can be the TenantId, a Custom domain added to the tenant, or the onmicrosoft.com-domain associated with the tenant.
This value will override any TenantId from a Configuration

```yaml
Type: String
Parameter Sets: (All)
Aliases: TenantName

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Configuration
The configuration to use to connect to Microsoft Graph.
This will override any global configuration from the loaded profile.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None. You cannot pipe objects to Connect-EvtGraph.
## OUTPUTS

### None.
## NOTES

## RELATED LINKS
