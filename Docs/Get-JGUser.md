---
external help file: JAGM-help.xml
Module Name: JAGM
online version:
schema: 2.0.0
---

# Get-JGUser

## SYNOPSIS
Gets one or more user from Microsoft Graph

## SYNTAX

```
Get-JGUser [[-ObjectId] <Object>] [[-Property] <String>] [-AdvancedQuery] [[-ExpandProperty] <String>]
 [[-Filter] <String>] [[-Search] <String>] [[-Sort] <String>] [[-Top] <Int32>] [<CommonParameters>]
```

## DESCRIPTION
Gets one or more user from Microsoft Graph.
Attempts to do so with the least amount of 'cost'.

## EXAMPLES

### EXAMPLE 1
```
Get-JGUser
Get all users in Microsoft Graph
```

## PARAMETERS

### -ObjectId
The ObjectId of the user to get from Graph.

```yaml
Type: Object
Parameter Sets: (All)
Aliases: UserId, Id, userPrincipalName

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Property
The properties of the user to get from Graph.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: Id,displayName,jobTitle,mail,officeLocation,userPrincipalName
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

### -ExpandProperty
Retrieves related resources..

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Filter
Filters results (rows).

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Search
Returns results based on search criteria.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Sort
Orders results.
To sort the results in ascending or descending order, append either asc or desc to the field name, separated by a space; for example, name%20desc.
If the sort order is not specified, the default (ascending order) is inferred.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Order, OrderBy

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Top
Sets the page size of results.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### [String] - Each string will be used as ObjectID
### [Object] - If the property ObjectId, UserID or Id exists, it will be attemted to be used as ObjectId.
## OUTPUTS

### [PSCustomObject[]] - One or many objects with user-information from Microsoft Graph.
## NOTES

## RELATED LINKS
