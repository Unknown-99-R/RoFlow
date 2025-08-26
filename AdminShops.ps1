# Shop administration utilities

# Load database helpers
. "$PSScriptRoot/LiteDbUtils.ps1" 2>$null

function Add-Shop {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Name
    )
    Initialize-Database
    Backup-Database
    $db = Get-Db
    try {
        $col = $db.GetCollection('shops')
        $col.EnsureIndex('Name', $true)
        $col.Upsert([pscustomobject]@{ Name = $Name }) | Out-Null
    } finally { $db.Dispose() }
}

function Remove-Shop {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Name
    )
    Initialize-Database
    Backup-Database
    $db = Get-Db
    try {
        $col = $db.GetCollection('shops')
        $col.DeleteMany([LiteDB.Query]::EQ('Name', $Name)) | Out-Null
    } finally { $db.Dispose() }
}

function List-Shops {
    [CmdletBinding()]
    param()
    Initialize-Database
    $db = Get-Db -ReadOnly
    try {
        $col = $db.GetCollection('shops')
        $col.FindAll() | Select-Object -ExpandProperty Name
    } finally { $db.Dispose() }
}

function Show-ShopMenu {
    do {
        Write-Host "`nShop Administration" -ForegroundColor Cyan
        Write-Host "1) List Shops"
        Write-Host "2) Add Shop"
        Write-Host "3) Remove Shop"
        Write-Host "4) Exit"
        $choice = Read-Host "Select an option"
        switch ($choice) {
            '1' { List-Shops | ForEach-Object { Write-Host $_ } }
            '2' {
                $name = Read-Host "Enter shop name"
                if ($name) { Add-Shop -Name $name }
            }
            '3' {
                $name = Read-Host "Enter shop name to remove"
                if ($name) { Remove-Shop -Name $name }
            }
            '4' { break }
            default { Write-Host "Invalid selection" -ForegroundColor Red }
        }
    } while ($choice -ne '4')
}

if (-not $MyInvocation.InvocationName) {
    Export-ModuleMember -Function Add-Shop,Remove-Shop,List-Shops
}

if ($MyInvocation.InvocationName -ne '.' -and $MyInvocation.InvocationName) {
    Show-ShopMenu
}
