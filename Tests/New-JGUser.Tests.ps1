<#
	Tests for New-JGUser.
	Should attemt to test as many of the main functionalities of the CMDlet as possible.

	New-JGUser should create users based on 4 different inputs:
	- Single UserObject supplied as parameter.
	- Multiple UserObject supplied as parameter
	- Single UserObject supplied via PipeLine
	- Multiple UserObject supplied via PipeLine
#>
BeforeAll {
	$files = Get-ChildItem (Join-Path '.' 'Source') -File -Recurse -Include *.ps1
	foreach($file in $files){
		. $file.FullName
	}

	$addperson1 =  [PSCustomObject]@{
		displayName = 'JGUser01'
		accountEnabled = $true
		mailNickname = 'JGUser01'
		passwordProfile = @{
			forceChangePasswordNextSignIn = $true
			password = "xWwvJ]6NMw+bWH-d"
		}
		userPrincipalName = 'JGUser01@contoso.com'
	}
	$addperson2 =  [PSCustomObject]@{
		displayName = 'JGUser02'
		accountEnabled = $true
		mailNickname = 'JGUser02'
		passwordProfile = @{
			forceChangePasswordNextSignIn = $true
			password = "xWwvJ]6NMw+bWH-d"
		}
		userPrincipalName = 'JGUser02@contoso.com'
	}
	$addperson3 =  [PSCustomObject]@{
		displayName = 'JGUser03'
		accountEnabled = $true
		mailNickname = 'JGUser03'
		passwordProfile = @{
			forceChangePasswordNextSignIn = $true
			password = "xWwvJ]6NMw+bWH-d"
		}
		userPrincipalName = 'JGUser03@contoso.com'
	}
	$addperson4 =  [PSCustomObject]@{
		displayName = 'JGUser04'
		accountEnabled = $true
		mailNickname = 'JGUser04'
		passwordProfile = @{
			forceChangePasswordNextSignIn = $true
			password = "xWwvJ]6NMw+bWH-d"
		}
		userPrincipalName = 'JGUser04@contoso.com'
	}
	$users = @($addperson1,$addperson2,$addperson3,$addperson4)
	$users = $users
}
Describe 'New-JGUser -UserObject:$Object' {
	Context " Minimum Object supplied" {
		BeforeAll {
		}

		It " Should return User" {
			Mock -CommandName Invoke-MgGraphRequest { Get-Content -Path '.\Tests\Resources\New-JGUser\addperson1.json' | ConvertFrom-Json -AsHashtable }
			$user = New-JGUser -UserObject:$addperson1
			$user.Id | Should -be '511c60fc-5cb9-4ca4-ba81-b7ccd7e2b9d4'
		}

		It " Should lack attribute" {
			$addpersontmp = $addperson1 | Select-Object -ExcludeProperty displayName
			{New-JGUser -UserObject:$addpersontmp} | Should -Throw
		}
	}
}

<#
Disabled this rule after adding concurrency in batching. Mocking commands in another thread is not possible.
Describe 'New-JGUser -UserObject:$Objects' {
	Context " Should run in batch-mode" {

		It " Should call Microsoft Graph a single time" {
			Mock -CommandName Invoke-MgGraphRequest { Get-Content -Path '.\Tests\Resources\New-JGUser\addpersonBatch.json' | ConvertFrom-Json -AsHashtable }
			Should -InvokeVerifiable
			$users = New-JGUser -UserObject:$users
			$users.Count | Should -Be 4
			Should -Invoke -CommandName Invoke-MgGraphRequest -Times 1
		}
	}
}
#>
Describe '$Object | New-JGUser' {
	Context " Minimum Object supplied" {
		BeforeAll {
		}

		It " Should return User" {
			Mock -CommandName Invoke-MgGraphRequest { Get-Content -Path '.\Tests\Resources\New-JGUser\addperson1.json' | ConvertFrom-Json -AsHashtable }
			$user = $addperson1 | New-JGUser
			$user.Id | Should -be '511c60fc-5cb9-4ca4-ba81-b7ccd7e2b9d4'
		}

		It " Should lack attribute" {
			$addpersontmp = $addperson1 | Select-Object -ExcludeProperty displayName
			{$addpersontmp | New-JGUser} | Should -Throw
		}
	}

}

Describe '$Objects | New-JGUser' {
	Context " Should run in pipeline" {

		It " Should call Microsoft Graph multiple times" {
			Mock -CommandName Invoke-MgGraphRequest { Get-Content -Path '.\Tests\Resources\New-JGUser\addperson1.json' | ConvertFrom-Json -AsHashtable }
			$users | New-JGUser
			Should -Invoke -CommandName Invoke-MgGraphRequest -Times 4
		}
	}
}