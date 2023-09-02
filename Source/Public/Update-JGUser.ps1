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
		ErrorMessage = "Supplied Object is invalid. Please supply a PSCustomObject containing minimum: 'Id'"
        )]
		[Alias("UserObject")]
		$Object
	)

	begin {
	}

	process {
		if($Object.Count -gt 1){
			$BatchObjects = foreach ($request in $Object) {
				New-JGraphBatchObject -Method GET -Url ('/users/' + $request.Id) -Body $request
			}
			if($PSCmdlet.ShouldProcess($BatchObjects)){
				Invoke-JGraphBatchRequest -BatchObjects $BatchObjects
			}
		} elseif ($user.count -eq 1) {
			$parameters = @{
				Method	= "GET"
				Uri 	= '/v1.0/users/' + $Object.Id
				Body    = $Object
				Headers = $headers
			}
			try{
				Write-Verbose "Invoke-MgGraphRequest @parameters $($parameters | ConvertTo-Json -Depth 5 -Compress)"
				if($PSCmdlet.ShouldProcess($Object)){
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