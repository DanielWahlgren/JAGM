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