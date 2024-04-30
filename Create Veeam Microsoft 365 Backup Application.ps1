Connect-MgGraph -Scopes AppRoleAssignment.ReadWrite.All,Application.ReadWrite.All -NoWelcome

# Required Graph and Exchange API Permissions for Veeam Backup for Microsoft 365 for Exchange support
$requiredGraphAccess = (@{
  "resourceAccess" = (
    @{
      id = "7ab1d382-f21e-4acd-a863-ba3e13f7da61"
      type = "Role"
    },
    @{
      id = "5b567255-7703-4780-807c-7be8301ae99b"
      type = "Role"
    },
    @{
      id = "06da0dbc-49e2-44d2-8312-53f166ab848a"
      type = "Scope"
    },
    @{
      id = "c5366453-9fb0-48a5-a156-24f0c49a4b84"
      type = "Scope"
    },
    @{
      id = "7427e0e9-2fba-42fe-b0c0-848c9e6a8182"
      type = "Scope"
    }
  )
  "resourceAppId" = "00000003-0000-0000-c000-000000000000"
})
$requiredExchangeAccess = (@{
  "resourceAccess" = (
    @{
      id = "dc50a0fb-09a3-484d-be87-e023b12c6440"
      type = "Role"
    },
    @{
      id = "dc890d15-9560-4a4c-9b7f-a736ec74ec40"
      type = "Role"
    },
    @{
      id = "3b5f3d61-589b-4a3c-a359-5dd4b5ee5bd5"
      type = "Scope"
    }
  )
  "resourceAppId" = "00000002-0000-0ff1-ce00-000000000000"
})

# create a KeyCredential from the provided certificate
$certificate = Get-PfxCertificate -Filepath $args[0]
$x509cert = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate2($certificate)

$keyCredential = @{
  Type='AsymmetricX509Cert';
  Usage='Verify';
  Key=$x509cert.RawData
}

Write-Output "Now Registering the Application"
$app = New-MgApplication  -DisplayName "Veeam Microsoft 365 Backup" `
                          -RequiredResourceAccess $requiredGraphAccess,$requiredExchangeAccess `
                          -KeyCredentials $keyCredential `
                          -PublicClient @{ `
                            RedirectUris = "http://localhost" `
                          } `
                         -DefaultRedirectUri http://localhost
$appId=$app.appId

Write-Output "Application registered. Please login to the Microsoft Entra admin center and consent to the API privileges required for Veeam to backup. The application will also need to be added an assignment to the Global Reader Administrative Role."
Write-Output "AzureAd:AppId $appId"
Write-Output "AzureAd:TenantId $($(Get-MgContext).TenantId)"