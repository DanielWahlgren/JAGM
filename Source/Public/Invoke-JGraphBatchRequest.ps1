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