---
external help file: JAGM-help.xml
Module Name: JAGM
online version:
schema: 2.0.0
---

# New-JGUser

## SYNOPSIS
Helper-function to create a user in Microsoft Graph.

## SYNTAX

```
New-JGUser [-Object] <Object> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Helper-function to create a user in Microsoft Graph.

## EXAMPLES

### EXAMPLE 1
```
New-JGUser $userObject
Creates a user
```

## PARAMETERS

### -Object
The Object to create in Microsoft Graph

```yaml
Type: Object
Parameter Sets: (All)
Aliases: UserObject

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
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

### [Object[]].
## OUTPUTS

### [System.Collections.Hashtable].
## NOTES

## RELATED LINKS
