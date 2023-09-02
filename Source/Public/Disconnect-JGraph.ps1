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