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