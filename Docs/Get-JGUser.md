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

### Default (Default)
```
Get-JGUser [-ObjectId <Object>] [-Property <String>] [-AdvancedQuery] [-Filter <String>] [-Search <String>]
 [-Sort <String>] [-Top <Int32>] [-ExpandProperty <String>] [<CommonParameters>]
```

### AppRoleAssignments
```
Get-JGUser [-ObjectId <Object>] [-Property <String>] [-AdvancedQuery] [-Filter <String>] [-Search <String>]
 [-Sort <String>] [-Top <Int32>] [-AppRoleAssignments] [<CommonParameters>]
```

### DirectReports
```
Get-JGUser [-ObjectId <Object>] [-Property <String>] [-AdvancedQuery] [-Filter <String>] [-Search <String>]
 [-Sort <String>] [-Top <Int32>] [-DirectReports] [<CommonParameters>]
```

### Extensions
```
Get-JGUser [-ObjectId <Object>] [-Property <String>] [-AdvancedQuery] [-Filter <String>] [-Search <String>]
 [-Sort <String>] [-Top <Int32>] [-Extensions] [<CommonParameters>]
```

### Manager
```
Get-JGUser [-ObjectId <Object>] [-Property <String>] [-AdvancedQuery] [-Filter <String>] [-Search <String>]
 [-Sort <String>] [-Top <Int32>] [-Manager] [<CommonParameters>]
```

### MemberOf
```
Get-JGUser [-ObjectId <Object>] [-Property <String>] [-AdvancedQuery] [-Filter <String>] [-Search <String>]
 [-Sort <String>] [-Top <Int32>] [-MemberOf] [<CommonParameters>]
```

### OwnedDevices
```
Get-JGUser [-ObjectId <Object>] [-Property <String>] [-AdvancedQuery] [-Filter <String>] [-Search <String>]
 [-Sort <String>] [-Top <Int32>] [-OwnedDevices] [<CommonParameters>]
```

### OwnedObjects
```
Get-JGUser [-ObjectId <Object>] [-Property <String>] [-AdvancedQuery] [-Filter <String>] [-Search <String>]
 [-Sort <String>] [-Top <Int32>] [-OwnedObjects] [<CommonParameters>]
```

### RegisteredDevices
```
Get-JGUser [-ObjectId <Object>] [-Property <String>] [-AdvancedQuery] [-Filter <String>] [-Search <String>]
 [-Sort <String>] [-Top <Int32>] [-RegisteredDevices] [<CommonParameters>]
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
Position: Named
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
Position: Named
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

### -Filter
Filters results (rows).

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
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
Position: Named
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
Position: Named
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
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExpandProperty
Retrieves related resources..

```yaml
Type: String
Parameter Sets: Default
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AppRoleAssignments
Represents the app roles a user has been granted for an application.
To better customise, instead use -Expand 'appRoleAssignments($Select=id)'

```yaml
Type: SwitchParameter
Parameter Sets: AppRoleAssignments
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -DirectReports
Adds the users for whom the selected user is a manager to the query. Returns the DirectReports with -Property properties.
To better customise, instead use -Expand 'directReports($Select=id)'

```yaml
Type: SwitchParameter
Parameter Sets: DirectReports
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Extensions
The collection of open extensions defined for the user.
To better customise, instead use -Expand 'extensions($Select=id)'

```yaml
Type: SwitchParameter
Parameter Sets: Extensions
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Manager
Adds the users manager to the query. Returns the Manager with -Property properties.
To better customise, instead use -Expand 'manager($Select=id)'

```yaml
Type: SwitchParameter
Parameter Sets: Manager
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -MemberOf
Adds the groups and directory roles that the user is a member of.
To better customise, instead use -Expand 'memberOf($Select=id)'

```yaml
Type: SwitchParameter
Parameter Sets: MemberOf
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -OwnedDevices
Adds the devices that are owned by the user.
To better customise, instead use -Expand 'ownedDevices($Select=id)'

```yaml
Type: SwitchParameter
Parameter Sets: OwnedDevices
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -OwnedObjects
Adds the directory objects that are owned by the user.
To better customise, instead use -Expand 'ownedObjects($Select=id)'

```yaml
Type: SwitchParameter
Parameter Sets: OwnedObjects
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -RegisteredDevices
Adds the devices that are registered for the user.
To better customise, instead use -Expand 'registeredDevices($Select=id)'

```yaml
Type: SwitchParameter
Parameter Sets: RegisteredDevices
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

### [String] - Each string will be used as ObjectID
### [Object] - If the property ObjectId, UserID or Id exists, it will be attemted to be used as ObjectId.
## OUTPUTS

### [PSCustomObject[]] - One or many objects with user-information from Microsoft Graph.
## NOTES

## RELATED LINKS
