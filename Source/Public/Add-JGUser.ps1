function Add-JGUser {
	<#
	.SYNOPSIS
		Helper-function to create a user in Microsoft Graph.

	.DESCRIPTION
		Helper-function to create a user in Microsoft Graph.

	.EXAMPLE
		PS> Add-JGUser $userObject
		Creates a user

	.INPUTS
		None. You cannot pipe objects to Disconnect-JGraph.

	.OUTPUTS
		None.
	#>
	[CmdletBinding()]
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
		ErrorMessage = "Supplied Object is invalid. Please supply a PSCustomObject containing minimum: 'accountEnabled','displayName','passwordProfile','userPrincipalName'"
        )]
		[Alias("UserObject")]
		$Object
	)

	begin {
		$headers = [System.Collections.Generic.Dictionary[string, string]]::new()
		$headers.Add('Content-Type','application/json')
	}

	process {
		if($Object.Count -gt 1){
			$BatchObjects = foreach ($request in $Object) {
				New-JGraphBatchObject -Method POST -Url '/users' -Body $request
			}
			Invoke-JGraphBatchRequest -BatchObjects $BatchObjects
		} else {
			$parameters = @{
				Method	= "POST"
				Uri 	= '/v1.0/users'
				Headers = $headers
				Body	= $Object | ConvertTo-Json
			}
			try{
				Write-Verbose "Invoke-MgGraphRequest @parameters $($parameters | ConvertTo-Json -Depth 5 -Compress)"
				$result = Invoke-MgGraphRequest @parameters
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
				$Err = $Error[0]
				Write-Warning $Err.Exception.Message
			}
		}
	}

	end {}
}