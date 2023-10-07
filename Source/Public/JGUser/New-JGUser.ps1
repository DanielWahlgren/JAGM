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