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