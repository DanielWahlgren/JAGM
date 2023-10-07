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