# Shop management functions for RoFlow

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
Import-Module (Join-Path $ScriptDir 'LiteDbUtils.ps1') -Force

function Get-Shops {
    $db = Get-Db -ReadOnly
    try {
        return $db.GetCollection('shops').FindAll() | ForEach-Object { $_.Name }
    } finally { $db.Dispose() }
}

function Add-Shop {
    param([string]$Name)
    Backup-Database
    $db = Get-Db
    try {
        $col = $db.GetCollection('shops')
        $col.Upsert([PSCustomObject]@{ _id = $Name; Name = $Name }) | Out-Null
    } finally { $db.Dispose() }
}

function Remove-Shop {
    param([string]$Name)
    Backup-Database
    $db = Get-Db
    try {
        $db.GetCollection('shops').Delete($Name) | Out-Null
    } finally { $db.Dispose() }
}

Export-ModuleMember -Function Get-Shops,Add-Shop,Remove-Shop
