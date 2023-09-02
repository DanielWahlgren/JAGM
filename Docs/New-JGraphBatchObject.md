---
external help file: JAGM-help.xml
Module Name: JAGM
online version:
schema: 2.0.0
---

# New-JGraphBatchObject

## SYNOPSIS
Helper-function to make batch-requests to Microsoft Graph.

## SYNTAX

```
New-JGraphBatchObject [-Method] <Object> [-Url] <Object> [[-Body] <Object>] [-AdvancedQuery]
 [<CommonParameters>]
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
Makes a new Batch-object for use in Batch-requests
```

## PARAMETERS

### -Method
The method to use for the request.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Url
The url to use for the request.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Body
The body to use for the request.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AdvancedQuery
The properties of the user to get from Graph.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None.
## OUTPUTS

### [System.Collections.Hashtable].
## NOTES

## RELATED LINKS
