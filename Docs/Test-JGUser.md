---
external help file: JAGM-help.xml
Module Name: JAGM
online version:
schema: 2.0.0
---

# Test-JGUser

## SYNOPSIS
Helper-function to verify a user is present and/or has the correct properties in Microsoft Graph.

## SYNTAX

```
Test-JGUser [[-ObjectId] <Object>] [[-Property] <String>] [<CommonParameters>]
```

## DESCRIPTION
Helper-function to verify a user is present and/or has the correct properties in Microsoft Graph.

## EXAMPLES

### EXAMPLE 1
```
Test-JGUser -ObjectId $person1
Test if user exists
```

## PARAMETERS

### -ObjectId
The ObjectId of the user to get from Graph.

```yaml
Type: Object
Parameter Sets: (All)
Aliases: UserId, Id

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
Default value: Id
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None.
## OUTPUTS

### None.
## NOTES

## RELATED LINKS
