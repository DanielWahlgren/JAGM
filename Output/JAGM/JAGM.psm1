### --- PUBLIC FUNCTIONS --- ###
#Region - Connect-JGraph.ps1
function Connect-JGraph {
	<#
	.SYNOPSIS
		Helper-function to connect to Microsoft Graph using a configuration from $PROFILE.

	.DESCRIPTION
		Helper-function to connect to Microsoft Graph using a configuration from the loaded profile.
		See Get-Help about_profiles for more information about the location and syntax of the different profiles avaliable in PowerShell.
		The Configuration will be used as-is, so for options, use Get-Help Connect-MgGraph

	.EXAMPLE
		PS> Connect-JGraph -TenantName:'contoso.onmicrosoft.com'
		Connect to the Contoso-tenant using the configuration found in the loaded profile.

	.INPUTS
		None. You cannot pipe objects to Connect-EvtGraph.

	.OUTPUTS
		None.
	#>
	[CmdletBinding(DefaultParameterSetName = 'Default')]
	param
	(
		[Parameter(Mandatory = $false, HelpMessage = 'Enter the desired tenant to connect to: client.onmicrosoft.com')]
		# The TenantId to use to connect to Microsoft Graph.
		# The TenantId can be the TenantId, a Custom domain added to the tenant, or the onmicrosoft.com-domain associated with the tenant.
		# This value will override any TenantId from a Configuration
		[ValidateNotNullorEmpty()]
		[Alias("TenantName")]
		[String]$TenantId,

		[Parameter(Mandatory = $false, HelpMessage = 'Supply a configuration-object for authenticating with Graph')]
		# The configuration to use to connect to Microsoft Graph.
		# This will override any global configuration from the loaded profile.
		[ValidateNotNullorEmpty()]
		$Configuration
	)

	begin {
		#None
		$Parameters = @{}
		if($PSBoundParameters.ContainsKey('TenantId')){
			$Parameters.Add('TenantId',$TenantId)
		}
		if($PSBoundParameters.ContainsKey('Configuration')){
			foreach($key in $Configuration.Keys){
				if(-not $Parameters.ContainsKey($key)){
					$Parameters.Add($key,$Configuration[$key])
				}
			}
		}
		if(-not [String]::IsNullOrEmpty($JAGMconfig)){
			foreach($key in $JAGMconfig.Keys){
				if(-not $Parameters.ContainsKey($key)){
					$Parameters.Add($key,$JAGMconfig[$key])
				}
			}
		}
	}

	process {
		Connect-MgGraph @Parameters -Verbose:$Verbose | Out-Null
	}

	end {}
}
Export-ModuleMember -Function Connect-JGraph
#EndRegion - Connect-JGraph.ps1
#Region - Disconnect-JGraph.ps1
function Disconnect-JGraph {
	<#
	.SYNOPSIS
		Helper-function to disconnect to Microsoft Graph.

	.DESCRIPTION
		This exists mostly to make use of Connect-JGraph and Disconnect-JGraph semantically relevant.

	.EXAMPLE
		PS> Disconnect-JGraph
		Disconnects the current MgGraph-connection.

	.INPUTS
		None. You cannot pipe objects to Disconnect-JGraph.

	.OUTPUTS
		None.
	#>
	[CmdletBinding()]
	param
	()

	begin {}

	process {
		Disconnect-MgGraph | Out-null
	}

	end {}
}
Export-ModuleMember -Function Disconnect-JGraph
#EndRegion - Disconnect-JGraph.ps1
#Region - Invoke-JGraphBatchRequest.ps1
function Invoke-JGraphBatchRequest {
	<#
	.SYNOPSIS
		Helper-function to make batch-requests to Microsoft Graph.

	.DESCRIPTION
		Helper-function to make batch-requests to Microsoft Graph.

	.EXAMPLE
		PS> $BatchObjects = foreach ($request in $user) {
				New-JGraphBatchObject -Method GET -Url ('/users/' + $request + $QueryString)
			}
			Invoke-JGraphBatchRequest -BatchObjects $BatchObjects
		Makes a new Batch-request

	.INPUTS
		[PSCustomObject]BatchObjects.

	.OUTPUTS
		None.
	#>
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'Endpoint', Justification='$Endpoint is used as a remote variable in the Foreach-Object -Parallel scriptblock')]
	[OutputType([System.Management.Automation.PSObject[]])]
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $false, HelpMessage = 'Submit BatchObjects', ValueFromPipeline = $true,ValueFromPipelineByPropertyName = $true)]
		# The batch-objects to use in the request.
		[ValidateNotNullorEmpty()]
		$BatchObjects,

		[Parameter(Mandatory = $false, HelpMessage = 'Select which endpoint to use, v1.0 or beta')]
		# The batch-endpoint to use in the request.
		[ValidateSet('v1.0','beta')]
		$Endpoint = 'v1.0'
	)

	process {
		$batchResult = [System.Collections.Concurrent.ConcurrentBag[System.Object]]::new()
		#Splitting the objects into batches of 20
		$script:counter = 0
		$Batches = $BatchObjects | Group-Object -Property { [math]::Floor($script:counter++ / 20) }

		$Batches | Foreach-Object -ThrottleLimit 5 -Parallel {
			$batch = $PSItem
			$collection = $using:batchResult
			[int]$requestID = 1
			foreach($request in $batch.Group){
				Add-Member -InputObject $request -Name 'id' -Value $requestID -MemberType NoteProperty
				$requestID++
			}
			$allBatchRequests =  [pscustomobject][ordered]@{
				requests = $batch.Group
			}
			$parameters = @{
				Method	= "POST"
				Uri 	= $using:Endpoint + '/$batch'
				Body	= $allBatchRequests | ConvertTo-Json -Depth 10 -Compress
				Headers = $headers
			}
			Write-Verbose "Invoke-MgGraphRequest @parameters $($parameters | ConvertTo-Json -Depth 5 -Compress)"
			$result = Invoke-MgGraphRequest @parameters
			foreach($item in $result.responses){
				if( -not [String]::IsNullOrEmpty($item.body) -and $item.body.ContainsKey('value')){
					foreach($o in $item.body.value){
						$collection.Add([PSCustomObject]$o)
					}
				} else {
					if([String]::IsNullOrEmpty($item.body.error)){
						$collection.Add(($item.body | Select-Object -ExcludeProperty '@odata.context'))
					} else {
						Write-Warning $item.body.error['message']
					}
				}
			}
		}
		[PSCustomObject[]]$batchResult
	}
}
Export-ModuleMember -Function Invoke-JGraphBatchRequest
#EndRegion - Invoke-JGraphBatchRequest.ps1
#Region - New-JGraphBatchObject.ps1
function New-JGraphBatchObject {
	<#
	.SYNOPSIS
		Helper-function to make batch-requests to Microsoft Graph.

	.DESCRIPTION
		Helper-function to make batch-requests to Microsoft Graph.

	.EXAMPLE
		PS> $BatchObjects = foreach ($request in $user) {
				New-JGraphBatchObject -Method GET -Url ('/users/' + $request + $QueryString)
			}
			Invoke-JGraphBatchRequest -BatchObjects $BatchObjects
		Makes a new Batch-object for use in Batch-requests

	.INPUTS
		None.

	.OUTPUTS
		[System.Collections.Hashtable].
	#>
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions','')]
	[OutputType('System.Collections.Hashtable')]
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true, HelpMessage = 'Which method to use')]
		# The method to use for the request.
		[ValidateSet('GET','POST','PUT','PATCH','DELETE')]
		$Method,
		[Parameter(Mandatory = $true, HelpMessage = 'Which URL to use')]
		# The url to use for the request.
		$Url,
		[Parameter(Mandatory = $false, HelpMessage = 'Supply a body with the request')]
		# The body to use for the request.
		$Body,

		[Parameter(Mandatory = $false, HelpMessage = 'Run as an advanced query')]
		# The properties of the user to get from Graph.
		[Switch]$AdvancedQuery
	)

	begin {
		$headers = @{}
		if($AdvancedQuery){
			$headers.Add('ConsistencyLevel','eventual')
		}
	}

	process {
		if($AdvancedQuery -and $Url -notlike '*$count*'){
			$Url + '&$count'
		}
		$object = @{
			method = $Method
			url    = $Url
		}
		if( -not [String]::IsNullOrEmpty($Body)){
			$object.add('body',$Body)
			$headers.Add('Content-Type','application/json')
		}
		if( -not [String]::IsNullOrEmpty($headers)){
			$object.Add('headers',$headers)
		}
		$object
	}
}
Export-ModuleMember -Function New-JGraphBatchObject
#EndRegion - New-JGraphBatchObject.ps1
#Region - Get-JGUser.ps1
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
			ParameterSetName = 'AppRoleAssignments',
			HelpMessage = 'Adds the app roles a user has been granted for an application.'
		)]
		# Represents the app roles a user has been granted for an application.
		# To better customise, instead use -Expand 'appRoleAssignments($Select=id)'
		[Switch]$AppRoleAssignments,

		[Parameter(
			Mandatory = $false,
			ParameterSetName = 'DirectReports',
			HelpMessage = 'Adds the users for whom the selected user is a manager to the query.'
		)]
		# Adds the users for whom the selected user is a manager to the query. Returns the DirectReports with -Property properties.
		# To better customise, instead use -Expand 'directReports($Select=id)'
		[Switch]$DirectReports,

		[Parameter(
			Mandatory = $false,
			ParameterSetName = 'Extensions',
			HelpMessage = 'Adds the collection of open extensions defined for the user.'
		)]
		# The collection of open extensions defined for the user.
		# To better customise, instead use -Expand 'extensions($Select=id)'
		[Switch]$Extensions,

		[Parameter(
			Mandatory = $false,
			ParameterSetName = 'Manager',
			HelpMessage = 'Adds the users manager to the query.'
		)]
		# Adds the users manager to the query. Returns the Manager with -Property properties.
		# To better customise, instead use -Expand 'manager($Select=id)'
		[Switch]$Manager,

		[Parameter(
			Mandatory = $false,
			ParameterSetName = 'MemberOf',
			HelpMessage = 'Adds the groups and directory roles that the user is a member of'
		)]
		# Adds the groups and directory roles that the user is a member of.
		# To better customise, instead use -Expand 'memberOf($Select=id)'
		[Switch]$MemberOf,

		[Parameter(
			Mandatory = $false,
			ParameterSetName = 'OwnedDevices',
			HelpMessage = 'Adds the devices that are owned by the user'
		)]
		# Adds the devices that are owned by the user.
		# To better customise, instead use -Expand 'ownedDevices($Select=id)'
		[Switch]$OwnedDevices,

		[Parameter(
			Mandatory = $false,
			ParameterSetName = 'OwnedObjects',
			HelpMessage = 'Adds the directory objects that are owned by the user.'
		)]
		# Adds the directory objects that are owned by the user.
		# To better customise, instead use -Expand 'ownedObjects($Select=id)'
		[Switch]$OwnedObjects,

		[Parameter(
			Mandatory = $false,
			ParameterSetName = 'RegisteredDevices',
			HelpMessage = 'Adds the devices that are registered for the user.'
		)]
		# Adds the devices that are registered for the user.
		# To better customise, instead use -Expand 'registeredDevices($Select=id)'
		[Switch]$RegisteredDevices
	)

	begin {
		if($AppRoleAssignments){
			$PSBoundParameters['ExpandProperty'] = $true
			$ExpandProperty = 'appRoleAssignments'
		}
		if($DirectReports){
			$PSBoundParameters['ExpandProperty'] = $true
			$ExpandProperty = 'directReports($Select=' + $Property + ')'
		}
		if($Extensions){
			$PSBoundParameters['ExpandProperty'] = $true
			$ExpandProperty = 'extensions($Select=Id)'
		}
		if($Manager){
			$PSBoundParameters['ExpandProperty'] = $true
			$ExpandProperty = 'manager($Select=' + $Property + ')'
		}
		if($MemberOf){
			$PSBoundParameters['ExpandProperty'] = $true
			$ExpandProperty = 'memberOf($Select=Id)'
		}
		if($OwnedDevices){
			$PSBoundParameters['ExpandProperty'] = $true
			$ExpandProperty = 'ownedDevices($Select=Id)'
		}
		if($OwnedObjects){
			$PSBoundParameters['ExpandProperty'] = $true
			$ExpandProperty = 'ownedObjects($Select=Id)'
		}
		if($RegisteredDevices){
			$PSBoundParameters['ExpandProperty'] = $true
			$ExpandProperty = 'registeredDevices($Select=)'
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
Export-ModuleMember -Function Get-JGUser
#EndRegion - Get-JGUser.ps1
#Region - New-JGUser.ps1
function New-JGUser {
	<#
	.SYNOPSIS
		Helper-function to create a user in Microsoft Graph.

	.DESCRIPTION
		Helper-function to create a user in Microsoft Graph.

	.EXAMPLE
		PS> New-JGUser $userObject
		Creates a user

	.INPUTS
		[Object[]].

	.OUTPUTS
		[System.Collections.Hashtable].
	#>
	[alias("Add-JGuser")]
	[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
	param
	(
		[Parameter(Mandatory = $true, Position = 0, HelpMessage = 'Object to create in Microsoft Graph', ValueFromPipeline = $true)]
		# The Object to create in Microsoft Graph
		[ValidateScript({
			$PSItem.GetType().Name -match 'Object' -and
			$PSItem.PSObject.Properties.Name -contains ('accountEnabled') -and
			$PSItem.PSObject.Properties.Name -contains ('displayName') -and
			$PSItem.PSObject.Properties.Name -contains ('passwordProfile') -and
			$PSItem.PSObject.Properties.Name -contains ('userPrincipalName')
		},
		ErrorMessage = "Supplied Object is invalid. Please supply a PSCustomObject containing minimum: 'accountEnabled','displayName','passwordProfile','userPrincipalName'")]
		[Alias("Object")]
		$UserObject
	)

	begin {
		$headers = [System.Collections.Generic.Dictionary[string, string]]::new()
		$headers.Add('Content-Type','application/json')
	}

	process {
		if($UserObject.Count -gt 1){
			$BatchObjects = foreach ($request in $UserObject) {
				New-JGraphBatchObject -Method POST -Url '/users' -Body $request
			}
			if($PSCmdlet.ShouldProcess($BatchObjects)){
				Invoke-JGraphBatchRequest -BatchObjects $BatchObjects -Verbose:$Verbose
			}
		} else {
			$parameters = @{
				Method	= "POST"
				Uri 	= '/v1.0/users'
				Headers = $headers
				Body	= $UserObject | ConvertTo-Json
			}
			try{
				Write-Verbose "Invoke-MgGraphRequest @parameters $($parameters | ConvertTo-Json -Depth 5 -Compress)"
				if($PSCmdlet.ShouldProcess($UserObject.displayName)){
					$result = Invoke-MgGraphRequest @parameters
				}
				#Invoke-MgGraphRequest -Method POST -Uri '/v1.0/users' -Headers $headers -Body $Object
				if($result.ContainsKey('value')){
					foreach($item in $result.value){
						[PSCustomObject]$item
					}
				} else {
					$result | Select-Object -ExcludeProperty '@odata.context'
				}
			}
			catch {
				if([String]::IsNullOrEmpty($Error[0])){
					Write-Error "Unknown error"
				} else {
					$Err = $Error[0]
					Write-Warning $Err.Exception.Message
				}
			}
		}
	}

	end {}
}
Export-ModuleMember -Function New-JGUser
#EndRegion - New-JGUser.ps1
#Region - Remove-JGUser.ps1
function Remove-JGUser {
	<#
	.SYNOPSIS
		Helper-function to remove a user from Microsoft Graph.

	.DESCRIPTION
		Helper-function to remove a user from Microsoft Graph.

	.EXAMPLE
		PS> Remove-JGUser $ObjectId
		Remove a user from Microsoft Graph.

	.INPUTS
		None.

	.OUTPUTS
		None.
	#>
	[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
	param
	(
		[Parameter(Mandatory = $true, HelpMessage = 'Enter the user to remove', ValueFromPipeline = $true,ValueFromPipelineByPropertyName = $true)]
		# The ObjectId of the user to get from Graph.
		[ValidateNotNullorEmpty()]
		[Alias("UserId","Id","userPrincipalName")]
		$ObjectId
	)

	begin {}

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
					$user += $item.userPrincipalName
				}
			}
		}
		if($user.Count -gt 1){
			$BatchObjects = foreach ($request in $user) {
				New-JGraphBatchObject -Method DELETE -Url ('/users/' + $request)
			}
			if($PSCmdlet.ShouldProcess($BatchObjects)){
				Invoke-JGraphBatchRequest -BatchObjects $BatchObjects
			}
		} elseif ($user.count -eq 1) {
			$parameters = @{
				Method	= "DELETE"
				Uri 	= '/v1.0/users/' + $user
				Headers = $headers
			}
			try{
				Write-Verbose "Invoke-MgGraphRequest @parameters $($parameters | ConvertTo-Json -Depth 5 -Compress)"
				if($PSCmdlet.ShouldProcess($user)){
					Invoke-MgGraphRequest @parameters
				}
			}
			catch {
				$Err = $Error[0]
				Write-Warning $Err.Exception.Message
			}
		}
	}

	end {}
}
Export-ModuleMember -Function Remove-JGUser
#EndRegion - Remove-JGUser.ps1
#Region - Test-JGUser.ps1
function Test-JGUser {
	<#
	.SYNOPSIS
		Helper-function to verify a user is present and/or has the correct properties in Microsoft Graph.

	.DESCRIPTION
		Helper-function to verify a user is present and/or has the correct properties in Microsoft Graph.

	.EXAMPLE
		PS> Test-JGUser -ObjectId $person1
		Test if user exists

	.INPUTS
		None.

	.OUTPUTS
		None.
	#>
	[OutputType('System.Boolean')]
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $false, HelpMessage = 'Enter the desired ObjectId', ValueFromPipeline = $true,ValueFromPipelineByPropertyName = $true)]
		# The ObjectId of the user to get from Graph.
		[ValidateNotNullorEmpty()]
		[Alias("UserId","Id")]
		$ObjectId,

		[Parameter(Mandatory = $false, HelpMessage = 'Enter the desired properties')]
		# The properties of the user to get from Graph.
		[String]$Property = "Id"
	)

	begin {
	}

	process {
		# Handle if the incoming values are a strings or objects.
		if($ObjectId.Count -gt 1){
			throw "Too many objects. Test-JGUser can only test one user at a time."
		}
		$user = [PSCustomObject]@{}
		foreach($item in $ObjectId){
			if($item.GetType().Name -eq 'String'){
				Add-Member -InputObject $user -Name 'Id' -Value $item -MemberType NoteProperty
			} elseif($item.GetType().Name -match 'Object'){
				foreach($prop in $item.PSObject.Properties){
					switch ($prop.Name) {
						ObjectId { Add-Member -InputObject $user -Name 'Id' -Value $prop.Value -MemberType NoteProperty }
						UserId { Add-Member -InputObject $user -Name 'Id' -Value $prop.Value -MemberType NoteProperty }
						Default { Add-Member -InputObject $user -Name $prop.Name -Value $prop.Value -MemberType NoteProperty }
					}
				}
			}
		}
		if( -not [String]::IsNullOrEmpty($user.Id)){
			$Property = $user.PSObject.Properties.Name -join ','
			$parameters = @{
				Method	= "GET"
				Uri 	= '/v1.0/users/' + $user.Id + '?$Select=' + $Property
			}
			try{
				Write-Verbose "Invoke-MgGraphRequest @parameters $($parameters | ConvertTo-Json -Depth 5 -Compress)"
				$result = Invoke-MgGraphRequest @parameters
				$GraphObject = $result | Select-Object -ExcludeProperty '@odata.context'
			}
			catch {
				$Err = $Error[0]
				Write-Warning $Err.Exception.Message
				return $false
			}

			if(Compare-Object -ReferenceObject $user -DifferenceObject $GraphObject -Property $user.PSObject.Properties.Name){
				#No match
				$false
			} else {
				#Its a match
				$true
			}
		} else {
			Write-Warning "No Id specified in object."
		}
	}

	end {}
}
Export-ModuleMember -Function Test-JGUser
#EndRegion - Test-JGUser.ps1
#Region - Test-JGUserPassword.ps1
function Test-JGUserPassword {
	<#
	.SYNOPSIS
		Helper-function to check a user's password against the organization's password validation policy.

	.DESCRIPTION
		Helper-function to check a user's password against the organization's password validation policy and report whether the password is valid.
		Currently only works on Beta, and only with Delegated permissions.

	.EXAMPLE
		PS> Test-JGUser -ObjectId $person1
		Test if user exists

	.INPUTS
		None.

	.OUTPUTS
		[System.Boolean].
	#>
	[OutputType('System.Boolean')]
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $false, HelpMessage = 'Enter the desired password', ValueFromPipeline = $true,ValueFromPipelineByPropertyName = $true)]
		# The passwordto verify against Graph.
		[ValidateNotNullorEmpty()]
		[SecureString]
		$Password
	)

	begin {
		$headers = [System.Collections.Generic.Dictionary[string, string]]::new()
		$headers.Add('Content-Type','application/json')
	}

	process {
		# Handle if the incoming values are a strings or objects.
		if($Password.Count -gt 1){
			throw "Too many objects. Test-JGUserPassword can only test one password at a time."
		}
		$Body = @{
			password = (ConvertFrom-SecureString -SecureString $Password -AsPlainText)
		}
		$parameters = @{
			Method	= "POST"
			Uri 	= '/beta/users/validatePassword'
			Headers = $headers
			Body    = $Body
		}
		try{
			Write-Verbose "Invoke-MgGraphRequest @parameters $($parameters | ConvertTo-Json -Depth 5 -Compress)"
			$result = Invoke-MgGraphRequest @parameters
			$GraphObject = $result | Select-Object -ExcludeProperty '@odata.context'
		}
		catch {
			$Err = $Error[0]
			Write-Warning $Err.Exception.Message
			return $false
		}
		Write-Verbose "Full response: $($GraphObject | ConvertTo-Json -Depth 5 -Compress)"
		$GraphObject.isValid
	}

	end {}
}
Export-ModuleMember -Function Test-JGUserPassword
#EndRegion - Test-JGUserPassword.ps1
#Region - Update-JGUser.ps1
function Update-JGUser {
	<#
	.SYNOPSIS
		Helper-function to update a users properties in Microsoft Graph.

	.DESCRIPTION
		Helper-function to update a users properties in Microsoft Graph.

	.EXAMPLE
		PS> Update-JGUser -Object $person1
		Update the user

	.INPUTS
		[Object] representing the user.

	.OUTPUTS
		None.
	#>
	[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
	param
	(
		[Parameter(Mandatory = $true, Position = 0, HelpMessage = 'Object to update in Microsoft Graph', ValueFromPipeline = $true)]
		# The Object to update in Microsoft Graph
		[ValidateScript({
			$PSItem.GetType().Name -match 'Object' -and
			$PSItem.PSObject.Properties.Name -contains ('Id')
		},
		ErrorMessage = "Supplied Object is invalid. Please supply a PSCustomObject containing minimum: 'Id'")]
		[Alias("UserObject")]
		$Object
	)

	begin {
	}

	process {
		if($Object.Count -gt 1){
			$BatchObjects = foreach ($request in $Object) {
				New-JGraphBatchObject -Method PATCH -Url ('/users/' + $request.Id) -Body $request
			}
			if($PSCmdlet.ShouldProcess($BatchObjects)){
				Invoke-JGraphBatchRequest -BatchObjects $BatchObjects
			}
		} elseif ($user.count -eq 1) {
			$parameters = @{
				Method	= "PATCH"
				Uri 	= '/v1.0/users/' + $Object.Id
				Body    = $Object
				Headers = $headers
			}
			try{
				Write-Verbose "Invoke-MgGraphRequest @parameters $($parameters | ConvertTo-Json -Depth 5 -Compress)"
				if($PSCmdlet.ShouldProcess($Object.Id)){
					$result = Invoke-MgGraphRequest @parameters
				}
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
		}
	}

	end {}
}
Export-ModuleMember -Function Update-JGUser
#EndRegion - Update-JGUser.ps1
### --- PRIVATE FUNCTIONS --- ###
