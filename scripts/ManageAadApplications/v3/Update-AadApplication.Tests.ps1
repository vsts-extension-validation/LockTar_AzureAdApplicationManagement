#Invoke-Pester -Output Detailed .\Update-AadApplication.Tests.ps1
#$result | ConvertTo-Json -Depth 15 | Write-Host

BeforeAll { 
    Remove-Module ManageAadApplications
    Import-Module .\ManageAadApplications.psm1
}

Describe 'Update-AadApplication' {
    Context "ObjectId" {
        BeforeEach { 
            $app1 = New-AzADApplication -DisplayName "AzureAdApplicationManagementTestApp1"
            $sp1 = Get-AzADApplication -ObjectId $app1.ObjectId | New-AzADServicePrincipal
            Start-Sleep 15
        }
        
        It "Given empty objectid should throw error" {
            { Update-AadApplication "" } | Should -Throw "Cannot validate argument on parameter 'ObjectId'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }

        It "Given invalid objectid should throw error" {
            { Update-AadApplication -ObjectId "foo" } | Should -Throw "Invalid object identifier 'foo'."
        }

        It "Given non existing objectid should throw error" {
            { Update-AadApplication -ObjectId 88a82126-c223-4f2e-b997-2fe44d9131ec } | Should -Throw "Resource '88a82126-c223-4f2e-b997-2fe44d9131ec' does not exist or one of its queried reference-property objects are not present."
        }

        It "Given only existing objectid should give app and sp back" {
            $result = Update-AadApplication -ObjectId $app1.ObjectId

            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.ServicePrincipal | Should -BeNullOrEmpty -Not
            $result.Application.DisplayName | Should -Be "AzureAdApplicationManagementTestApp1"
            $result.ServicePrincipal.DisplayName | Should -Be "AzureAdApplicationManagementTestApp1"
        }
        
        AfterEach { 
            Get-AzADApplication -DisplayName "AzureAdApplicationManagementTestApp1" | Remove-AzADApplication -Force
        }
    }

    Context "ResourceAccessFilePath" {
        BeforeEach { 
            $app1 = New-AzADApplication -DisplayName "AzureAdApplicationManagementTestApp1"
            $sp1 = Get-AzADApplication -ObjectId $app1.ObjectId | New-AzADServicePrincipal
            Start-Sleep 15
        }

        It "Given empty ResourceAccessFilePath should skip update" {
            { Update-AadApplication -ObjectId $app1.ObjectId -ResourceAccessFilePath "" } | Should -Throw -Not
        }

        It "Given invalid ResourceAccessFilePath should throw error" {
            { Update-AadApplication -ObjectId $app1.ObjectId -ResourceAccessFilePath $PSScriptRoot"\..\..\Test-RequiredResourceAccessInvalidName.json" } | Should -Throw "Invalid file path for ResourceAccessFilePath"
        }

        It "Given ResourceAccessFilePath should update ResourceAccess" {
            $result = Update-AadApplication -ObjectId $app1.ObjectId -ResourceAccessFilePath $PSScriptRoot"\..\..\Test-RequiredResourceAccess.json"

            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.RequiredResourceAccess | Should -BeNullOrEmpty -Not
            $result.RequiredResourceAccess.Count | Should -Be 2
        }
        
        AfterEach { 
            Get-AzADApplication -DisplayName "AzureAdApplicationManagementTestApp1" | Remove-AzADApplication -Force
        }
    }

    Context "AppRolesFilePath" {
        BeforeEach { 
            $app1 = New-AzADApplication -DisplayName "AzureAdApplicationManagementTestApp1"
            $sp1 = Get-AzADApplication -ObjectId $app1.ObjectId | New-AzADServicePrincipal
            Start-Sleep 15
        }

        It "Given empty AppRolesFilePath should throw error" {
            { Update-AadApplication -ObjectId $app1.ObjectId -AppRolesFilePath "" } | Should -Throw -Not
        }

        It "Given invalid AppRolesFilePath should throw error" {
            { Update-AadApplication -ObjectId $app1.ObjectId -AppRolesFilePath $PSScriptRoot"\..\..\Test-AppRolesInvalidName.json" } | Should -Throw "Invalid file path for AppRolesFilePath"
        }

        It "Given AppRolesFilePath should update AppRoles" {
            $result = Update-AadApplication -ObjectId $app1.ObjectId -AppRolesFilePath $PSScriptRoot"\..\..\Test-AppRoles.json"

            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.RequiredResourceAccess.Count | Should -Be 0
            $result.AppRoles | Should -BeNullOrEmpty -Not
            $result.AppRoles.Count | Should -Be 3
        }
        
        AfterEach { 
            Get-AzADApplication -DisplayName "AzureAdApplicationManagementTestApp1" | Remove-AzADApplication -Force
        }
    }

    Context "DisplayName" {
        BeforeEach { 
            $app1 = New-AzADApplication -DisplayName "AzureAdApplicationManagementTestApp1"
            $sp1 = Get-AzADApplication -ObjectId $app1.ObjectId | New-AzADServicePrincipal
            Start-Sleep 15
        }

        It "Given no DisplayName should skip update" {
            $result = Update-AadApplication -ObjectId $app1.ObjectId

            $result | Should -BeNullOrEmpty -Not
        }

        It "Given empty DisplayName should throw error" {
            { Update-AadApplication -ObjectId $app1.ObjectId -DisplayName "" } | Should -Throw "Cannot validate argument on parameter 'DisplayName'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }        

        It "Given DisplayName should update value" {
            $result = Update-AadApplication -ObjectId $app1.ObjectId -DisplayName "AzureAdApplicationManagementTestApp1NewName"

            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.Application.DisplayName | Should -Be "AzureAdApplicationManagementTestApp1NewName"
            $result.ServicePrincipal.DisplayName | Should -Be "AzureAdApplicationManagementTestApp1NewName"
        }
        
        AfterEach { 
            Get-AzADApplication -ObjectId $app1.ObjectId | Remove-AzADApplication -Force
        }
    }

    Context "IdentifierUri" {
        BeforeEach { 
            $app1 = New-AzADApplication -DisplayName "AzureAdApplicationManagementTestApp1"
            $sp1 = Get-AzADApplication -ObjectId $app1.ObjectId | New-AzADServicePrincipal
            Start-Sleep 15
        }

        It "Given no IdentifierUri should skip update" {
            $result = Update-AadApplication -ObjectId $app1.ObjectId

            $result | Should -BeNullOrEmpty -Not
        }

        It "Given empty IdentifierUri should throw error" {
            { Update-AadApplication -ObjectId $app1.ObjectId -IdentifierUri "" } | Should -Throw "Cannot validate argument on parameter 'IdentifierUri'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }        

        It "Given IdentifierUri should update value" {
            $result = Update-AadApplication -ObjectId $app1.ObjectId -IdentifierUri "https://ralphjansenoutlook.onmicrosoft.com/AzureAdApplicationManagementTestApp1"

            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.Application.IdentifierUris | Should -Be "https://ralphjansenoutlook.onmicrosoft.com/AzureAdApplicationManagementTestApp1"
        }
        
        AfterEach { 
            Get-AzADApplication -ObjectId $app1.ObjectId | Remove-AzADApplication -Force
        }
    }

    Context "HomePage" {
        BeforeEach { 
            $app1 = New-AzADApplication -DisplayName "AzureAdApplicationManagementTestApp1"
            $sp1 = Get-AzADApplication -ObjectId $app1.ObjectId | New-AzADServicePrincipal
            Start-Sleep 15
        }

        It "Given no HomePage should skip update" {
            $result = Update-AadApplication -ObjectId $app1.ObjectId

            $result | Should -BeNullOrEmpty -Not
            $result.Application.HomePage | Should -BeNullOrEmpty
            $result.ServicePrincipal.HomePage | Should -BeNullOrEmpty
        }

        It "Given app without HomePage, set HomePage to null should leave the app as is" {
            $result = Update-AadApplication -ObjectId $app1.ObjectId -HomePage $null            

            $result | Should -BeNullOrEmpty -Not
            $result.Application.HomePage | Should -BeNullOrEmpty
            $result.ServicePrincipal.HomePage | Should -BeNullOrEmpty
        }

        It "Given app without HomePage, set HomePage to empty string should leave the app as is" {
            $result = Update-AadApplication -ObjectId $app1.ObjectId -HomePage ""

            $result | Should -BeNullOrEmpty -Not
            $result.Application.HomePage | Should -BeNullOrEmpty
            $result.ServicePrincipal.HomePage | Should -BeNullOrEmpty
        }

        It "Given app with HomePage, set HomePage to null should throw error" {
            Update-AadApplication -ObjectId $app1.ObjectId -HomePage "https://sampleurl.info"
            
            { Update-AadApplication -ObjectId $app1.ObjectId -HomePage $null } | Should -Throw "Cannot validate argument on parameter 'HomePage'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }

        It "Given app with HomePage, set HomePage to empty string should throw error" {
            Update-AadApplication -ObjectId $app1.ObjectId -HomePage "https://sampleurl.info"

            { Update-AadApplication -ObjectId $app1.ObjectId -HomePage "" } | Should -Throw "Cannot validate argument on parameter 'HomePage'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }

        It "Given app without HomePage, set HomePage with correct value should update value" {
            $result = Update-AadApplication -ObjectId $app1.ObjectId -HomePage "https://sampleurl.info"
            
            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.Application.HomePage | Should -Be "https://sampleurl.info"
        }

        It "Given app with HomePage, set new HomePage should update old value" {
            $result = Update-AadApplication -ObjectId $app1.ObjectId -HomePage "https://old.info"
            $result = Update-AadApplication -ObjectId $app1.ObjectId -HomePage "https://sampleurl.info"

            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.Application.HomePage | Should -Be "https://sampleurl.info"
        }
        
        AfterEach { 
            Get-AzADApplication -ObjectId $app1.ObjectId | Remove-AzADApplication -Force
        }
    }

    Context "AvailableToOtherTenants" {
        BeforeEach { 
            $app1 = New-AzADApplication -DisplayName "AzureAdApplicationManagementTestApp1" -IdentifierUris "https://ralphjansenoutlook.onmicrosoft.com/AzureAdApplicationManagementTestApp1"
            $sp1 = Get-AzADApplication -ObjectId $app1.ObjectId | New-AzADServicePrincipal
            Start-Sleep 15
        }

        It "Given no AvailableToOtherTenants should skip update" {
            $result = Update-AadApplication -ObjectId $app1.ObjectId

            $result | Should -BeNullOrEmpty -Not
            $result.Application.AvailableToOtherTenants | Should -Be $false
        }

        It "Given AvailableToOtherTenants should update value" {
            $result = Update-AadApplication -ObjectId $app1.ObjectId -AvailableToOtherTenants $true

            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.Application.AvailableToOtherTenants | Should -Be $true
        }

        It "Given new AvailableToOtherTenants should update old AvailableToOtherTenants value" {
            $result = Update-AadApplication -ObjectId $app1.ObjectId -AvailableToOtherTenants $true
            $result = Update-AadApplication -ObjectId $app1.ObjectId -AvailableToOtherTenants $false

            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.Application.AvailableToOtherTenants | Should -Be $false
        }
        
        AfterEach { 
            Get-AzADApplication -ObjectId $app1.ObjectId | Remove-AzADApplication -Force
        }
    }

    Context "ReplyUrls" {
        BeforeEach { 
            $app1 = New-AzADApplication -DisplayName "AzureAdApplicationManagementTestApp1"
            $sp1 = Get-AzADApplication -ObjectId $app1.ObjectId | New-AzADServicePrincipal
            Start-Sleep 15
        }

        It "Given no ReplyUrls should skip update" {
            $result = Update-AadApplication -ObjectId $app1.ObjectId

            $result | Should -BeNullOrEmpty -Not
            $result.Application.ReplyUrls | Should -BeNullOrEmpty
        }

        It "Given app without ReplyUrls, set null as ReplyUrls should leave the app as is" {
            $result = Update-AadApplication -ObjectId $app1.ObjectId -ReplyUrls $null

            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.Application.ReplyUrls | Should -BeNullOrEmpty
        }

        It "Given app without ReplyUrls, set empty as ReplyUrls should leave the app as is" {
            $result = Update-AadApplication -ObjectId $app1.ObjectId -ReplyUrls ""

            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.Application.ReplyUrls | Should -BeNullOrEmpty
        }

        It "Given app with ReplyUrls, set empty ReplyUrls should throw error" {
            Update-AadApplication -ObjectId $app1.ObjectId -ReplyUrls "https://sampleurl.info"

            { Update-AadApplication -ObjectId $app1.ObjectId -ReplyUrls "" } | Should -Throw "ReplyUrls can not be an empty string"
        }

        It "Given app with ReplyUrls, set null as ReplyUrls should remove them" {
            Update-AadApplication -ObjectId $app1.ObjectId -ReplyUrls "https://sampleurl.info"

            { Update-AadApplication -ObjectId $app1.ObjectId -ReplyUrls $null } | Should -Throw "ReplyUrls can not be an empty string"
        }

        It "Given app without ReplyUrls, set ReplyUrls should update value" {
            $result = Update-AadApplication -ObjectId $app1.ObjectId -ReplyUrls "https://sampleurl.info"

            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.Application.ReplyUrls | Should -Be "https://sampleurl.info"
        }

        It "Given app with ReplyUrls, set new ReplyUrls should update old value" {
            $result = Update-AadApplication -ObjectId $app1.ObjectId -ReplyUrls "https://old.info"
            $result = Update-AadApplication -ObjectId $app1.ObjectId -ReplyUrls "https://sampleurl.info"

            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.Application.ReplyUrls | Should -Be "https://sampleurl.info"
        }
        
        AfterEach { 
            Get-AzADApplication -ObjectId $app1.ObjectId | Remove-AzADApplication -Force
        }
    }

    Context "Owners" {
        BeforeEach { 
            $app1 = New-AzADApplication -DisplayName "AzureAdApplicationManagementTestApp1"
            $sp1 = Get-AzADApplication -ObjectId $app1.ObjectId | New-AzADServicePrincipal
            Start-Sleep 15
        }

        It "Given no Owners should skip update" {
            $result = Update-AadApplication -ObjectId $app1.ObjectId

            $result | Should -BeNullOrEmpty -Not
            $result.Owners | Should -BeNullOrEmpty
        }

        It "Given empty Owners should throw error" {
            { Update-AadApplication -ObjectId $app1.ObjectId -Owners "" } | Should -Throw "Cannot validate argument on parameter 'Owners'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }

        It "Given Owners should update value" {
            $result = Update-AadApplication -ObjectId $app1.ObjectId -Owners "bf41f70e-be3c-473a-b594-1e7c57b28da4"

            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.Owners[0].ObjectId | Should -Be "bf41f70e-be3c-473a-b594-1e7c57b28da4"
        }

        It "Given new Owners should update old Owners value" {
            $result = Update-AadApplication -ObjectId $app1.ObjectId -Owners "1dbbdd07-9978-489f-b676-6c084a890b49"
            $result = Update-AadApplication -ObjectId $app1.ObjectId -Owners "bf41f70e-be3c-473a-b594-1e7c57b28da4"

            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.Owners[0].ObjectId | Should -Be "bf41f70e-be3c-473a-b594-1e7c57b28da4"
        }
        
        AfterEach { 
            Get-AzADApplication -ObjectId $app1.ObjectId | Remove-AzADApplication -Force
        }
    }

    Context "Secrets" {
        BeforeEach { 
            $app1 = New-AzADApplication -DisplayName "AzureAdApplicationManagementTestApp1"
            $sp1 = Get-AzADApplication -ObjectId $app1.ObjectId | New-AzADServicePrincipal
            Start-Sleep 15
        }

        It "Given no Secrets should skip update" {
            $result = Update-AadApplication -ObjectId $app1.ObjectId

            $result | Should -BeNullOrEmpty -Not
        }

        It "Given empty Secrets should skip update" {
            { Update-AadApplication -ObjectId $app1.ObjectId -Secrets "" } | Should -Throw -Not
        }

        It "Given Secrets should update value" {
            $secrets = '[{ ''Description'': ''testkey'', ''EndDate'': ''01/12/2022'' }]'
            $secretsArray = $secrets | ConvertFrom-Json

            # Check output for the above secret because will not send to output for security reasons
            $result = Update-AadApplication -ObjectId $app1.ObjectId -Secrets $secretsArray

            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
        }
        
        AfterEach { 
            Get-AzADApplication -ObjectId $app1.ObjectId | Remove-AzADApplication -Force
        }
    }

    Context "AppRoleAssignmentRequired" {
        BeforeEach { 
            $app1 = New-AzADApplication -DisplayName "AzureAdApplicationManagementTestApp1"
            $sp1 = Get-AzADApplication -ObjectId $app1.ObjectId | New-AzADServicePrincipal
            Start-Sleep 15
        }

        It "Given no AppRoleAssignmentRequired should skip update" {
            $result = Update-AadApplication -ObjectId $app1.ObjectId

            $result | Should -BeNullOrEmpty -Not
            $result.SpAppRoleAssignmentRequired | Should -Be $false
        }

        It "Given AppRoleAssignmentRequired should update value" {
            $result = Update-AadApplication -ObjectId $app1.ObjectId -DisplayName "AzureAdApplicationManagementTestApp2" -AppRoleAssignmentRequired $true -HomePage "https://test.com"

            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.SpAppRoleAssignmentRequired | Should -Be $true
            $result.Application.DisplayName | Should -Be "AzureAdApplicationManagementTestApp2"
            $result.ServicePrincipal.DisplayName | Should -Be "AzureAdApplicationManagementTestApp2"
            $result.Application.HomePage | Should -Be "https://test.com"
        }

        It "Given new AppRoleAssignmentRequired should update old AppRoleAssignmentRequired value" {
            $result = Update-AadApplication -ObjectId $app1.ObjectId -AppRoleAssignmentRequired $true
            $result = Update-AadApplication -ObjectId $app1.ObjectId -AppRoleAssignmentRequired $false

            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.SpAppRoleAssignmentRequired | Should -Be $false
        }
        
        AfterEach { 
            Get-AzADApplication -ObjectId $app1.ObjectId | Remove-AzADApplication -Force
        }
    }

    Context "Oauth2AllowImplicitFlow" {
        BeforeEach { 
            $app1 = New-AzADApplication -DisplayName "AzureAdApplicationManagementTestApp1"
            $sp1 = Get-AzADApplication -ObjectId $app1.ObjectId | New-AzADServicePrincipal
            Start-Sleep 15
        }

        It "Given no Oauth2AllowImplicitFlow should skip update" {
            $result = Update-AadApplication -ObjectId $app1.ObjectId

            $result | Should -BeNullOrEmpty -Not
            $result.AppOauth2AllowImplicitFlow | Should -Be $false
        }

        It "Given Oauth2AllowImplicitFlow should update value" {
            $result = Update-AadApplication -ObjectId $app1.ObjectId -Oauth2AllowImplicitFlow $true

            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.AppOauth2AllowImplicitFlow | Should -Be $true
        }

        It "Given new Oauth2AllowImplicitFlow should update old Oauth2AllowImplicitFlow value" {
            $result = Update-AadApplication -ObjectId $app1.ObjectId -Oauth2AllowImplicitFlow $true
            $result = Update-AadApplication -ObjectId $app1.ObjectId -Oauth2AllowImplicitFlow $false

            $result | Should -BeNullOrEmpty -Not
            $result.Application | Should -BeNullOrEmpty -Not
            $result.AppOauth2AllowImplicitFlow | Should -Be $false
        }
        
        AfterEach { 
            Get-AzADApplication -ObjectId $app1.ObjectId | Remove-AzADApplication -Force
        }
    }
}
