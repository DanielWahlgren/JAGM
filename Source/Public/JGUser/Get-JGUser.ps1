function Get-JGUser {
	<#
	.SYNOPSIS
		Gets one or more user from Microsoft Graph

	.DESCRIPTION
		Gets one or more user from Microsoft Graph. Attempts to do so with the least amount of 'cost'.
		To assist with discovery, we attempt to add parameters for additional functionality of the API.
		For example adding -IncludeManager instead of requireing -Expand 'manager'

	.EXAMPLE
		PS> Get-JGUser
		Get all users in Microsoft Graph

	.INPUTS
		[String] - Each string will be used as ObjectID
		[Object] - If the property ObjectId, UserID or Id exists, it will be attemted to be used as ObjectId.

	.OUTPUTS
		[PSCustomObject[]] - One or many objects with user-information from Microsoft Graph.
	#>
	[CmdletBinding(DefaultParameterSetName='Default')]
	param
	(
		[Parameter(
			Mandatory = $false,
			HelpMessage = 'Enter the desired ObjectId',
			ValueFromPipeline = $true,
			ValueFromPipelineByPropertyName = $true
		)]
		# The ObjectId of the user to get from Graph.
		[ValidateNotNullorEmpty()]
		[Alias("UserId","Id","userPrincipalName")]
		$ObjectId,

		[Parameter(
			Mandatory = $false,
			HelpMessage = 'Enter the desired properties'
		)]
		# The properties of the user to get from Graph.
		[String]$Property = "Id,displayName,jobTitle,mail,officeLocation,userPrincipalName",

		[Parameter(
			Mandatory = $false,
			HelpMessage = 'Run as an advanced query'
		)]
		# The properties of the user to get from Graph.
		[Switch]$AdvancedQuery,

		[Parameter(
			Mandatory = $false,
			HelpMessage = 'Filters results (rows).'
		)]
		# Filters results (rows).
		[String]$Filter,

		[Parameter(
			Mandatory = $false,
			HelpMessage = 'Returns results based on search criteria.'
		)]
		# Returns results based on search criteria.
		[String]$Search,

		[Parameter(
			Mandatory = $false,
			HelpMessage = 'Orders results. For descending order, append '
		)]
		# Orders results.
		# To sort the results in ascending or descending order, append either asc or desc to the field name,
		# separated by a space; for example, name%20desc. If the sort order is not specified, the default (ascending order)
		# is inferred.
		[Alias("Order","OrderBy")]
		[String]$Sort,

		[Parameter(
			Mandatory = $false,
			HelpMessage = 'Sets the page size of results.'
		)]
		# Sets the page size of results.
		[int]$Top,

		[Parameter(
			Mandatory = $false,
			ParameterSetName = 'Default',
			HelpMessage = 'Retrieves related resources.'
		)]
		# Retrieves related resources.
		[String]$ExpandProperty,

		[Parameter(
			Mandatory = $false,
			ParameterSetName = 'IncludeManager',
			HelpMessage = 'Adds the users manager to the query.'
		)]
		# Adds the users manager to the query. Returns the Manager with -Property properties.
		# To better customise, instead use -Expand 'manager($Select=id,userPrincipalname)'
		[Switch]$IncludeManager,

		[Parameter(
			Mandatory = $false,
			ParameterSetName = 'IncludeDirectReports',
			HelpMessage = 'Adds the users for whom the selected user is a manager to the query.'
		)]
		# Adds the users for whom the selected user is a manager to the query. Returns the DirectReports with -Property properties.
		# To better customise, instead use -Expand 'directReports($Select=id,userPrincipalname)'
		[Switch]$IncludeDirectReports
	)

	begin {
		if($IncludeManager){
			$PSBoundParameters['ExpandProperty'] = $true
			$ExpandProperty = 'manager($Select=' + $Property + ')'
		}
		if($IncludeDirectReports){
			$PSBoundParameters['ExpandProperty'] = $true
			$ExpandProperty = 'directReports($Select=' + $Property + ')'
		}

		#Construct the basics for the query based on supplied parameters
		$headers = @{}
		if($AdvancedQuery){
			$headers.Add('ConsistencyLevel','eventual')
			$count = '&$count'
		}
		$QueryString = '?$Select=' + $Property
		if($PSBoundParameters['ExpandProperty']){
			$QueryString += '&$expand=' + $ExpandProperty
		}
		if($PSBoundParameters['Filter']){
			$QueryString += '&$filter=' + $Filter
		}
		if($PSBoundParameters['Search']){
			$QueryString += '&$search=' + $Search
		}
		if($PSBoundParameters['Sort']){
			$QueryString += '&$orderby=' + $Sort
		}
		if($PSBoundParameters['Top']){
			$QueryString += '&$top=' + $Top
		}
		$QueryString += $count
	}

	process {
		# Handle if the incoming values are a strings or objects.
		$user = @()
		foreach($item in $ObjectId){
			if($item.GetType().Name -eq 'String'){
				$user += $item
			} elseif($item.GetType().Name -match 'Object'){
				if( -not [String]::IsNullOrEmpty($item.ObjectId)){
					$user += $item.ObjectId
				} elseif ( -not [String]::IsNullOrEmpty($item.UserId)) {
					$user += $item.UserId
				} elseif ( -not [String]::IsNullOrEmpty($item.Id)) {
					$user += $item.Id
				} elseif ( -not [String]::IsNullOrEmpty($item.userPrincipalName)) {
					$user += $item.Id
				}
			}
		}

		if($user.Count -gt 1){
			$BatchObjects = foreach ($request in $user) {
				New-JGraphBatchObject -Method GET -Url ('/users/' + $request + $QueryString)
			}
			Invoke-JGraphBatchRequest -BatchObjects $BatchObjects

		} elseif ($user.count -eq 1) {
			$parameters = @{
				Method	= "GET"
				Uri 	= '/v1.0/users/' + $user + $QueryString
				Headers = $headers
			}
			try{
				Write-Verbose "Invoke-MgGraphRequest @parameters $($parameters | ConvertTo-Json -Depth 5 -Compress)"
				$result = Invoke-MgGraphRequest @parameters
				if($result.ContainsKey('value')){
					foreach($item in $result.value){
						[PSCustomObject]$item
					}
				} else {
					$result | Select-Object -ExcludeProperty '@odata.context'
				}
			}
			catch {
				$Err = $Error[0]
				Write-Warning $Err.Exception.Message
			}
		} else {
			$parameters = @{
				Method	= "GET"
				Uri 	= '/v1.0/users/' + $QueryString
				Headers = $headers
			}
			Write-Verbose "Invoke-MgGraphRequest @parameters $($parameters | ConvertTo-Json -Depth 5 -Compress)"
			$result = Invoke-MgGraphRequest @parameters
			if($result.ContainsKey('value')){
				foreach($item in $result.value){
					[PSCustomObject]$item
				}
			} else {
				$result | Select-Object -ExcludeProperty '@odata.context'
			}
		}
	}

	end {}
}