---
external help file: JAGM-help.xml
Module Name: JAGM
online version:
schema: 2.0.0
---

# Remove-JGUser

## SYNOPSIS
Helper-function to remove a user from Microsoft Graph.

## SYNTAX

```
Remove-JGUser [-ObjectId] <Object> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Helper-function to remove a user from Microsoft Graph.

## EXAMPLES

### EXAMPLE 1
```
Remove-JGUser $ObjectId
Remove a user from Microsoft Graph.
```

## PARAMETERS

### -ObjectId
The ObjectId of the user to get from Graph.

```yaml
Type: Object
Parameter Sets: (All)
Aliases: UserId, Id, userPrincipalName

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
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
