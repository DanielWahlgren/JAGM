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