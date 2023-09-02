---
external help file: JAGM-help.xml
Module Name: JAGM
online version:
schema: 2.0.0
---

# Invoke-JGraphBatchRequest

## SYNOPSIS
Helper-function to make batch-requests to Microsoft Graph.

## SYNTAX

```
Invoke-JGraphBatchRequest [[-BatchObjects] <Object>] [<CommonParameters>]
```

## DESCRIPTION
Helper-function to make batch-requests to Microsoft Graph.

## EXAMPLES

### EXAMPLE 1
```
$BatchObjects = foreach ($request in $user) {
		New-JGraphBatchObject -Method GET -Url ('/users/' + $request + $QueryString)
	}
	Invoke-JGraphBatchRequest -BatchObjects $BatchObjects
Makes a new Batch-request
```

## PARAMETERS

### -BatchObjects
The batch-objects to use in the request.

```yaml
Type: Object
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

### [PSCustomObject]BatchObjects.
## OUTPUTS

### None.
## NOTES

## RELATED LINKS
