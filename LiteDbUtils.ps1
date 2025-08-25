# LiteDB utility functions for RoFlow

# Paths for configuration
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$configFile   = Join-Path $ScriptDir 'config.json'
$dbConfigFile = Join-Path $ScriptDir 'dbconfig.json'

function Get-DatabasePath {
    if (Test-Path $dbConfigFile) {
        try {
            return (Get-Content $dbConfigFile -Raw | ConvertFrom-Json).DbPath
        } catch {}
    }
    Add-Type -AssemblyName System.Windows.Forms
    $dlg = New-Object System.Windows.Forms.OpenFileDialog
    $dlg.Title  = 'Select LiteDB database file'
    $dlg.Filter = 'LiteDB Files (*.db)|*.db|All Files (*.*)|*.*'
    if ($dlg.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        @{ DbPath = $dlg.FileName } | ConvertTo-Json | Set-Content $dbConfigFile
        return $dlg.FileName
    } else {
        throw 'Database path selection cancelled.'
    }
}

function Get-ActiveShop {
    if (Test-Path $configFile) {
        try { return (Get-Content $configFile -Raw | ConvertFrom-Json).Shop } catch {}
    }
    return $null
}

function Set-ActiveShop {
    param([string]$Shop)
    $cfg = if (Test-Path $configFile) { Get-Content $configFile -Raw | ConvertFrom-Json } else { [pscustomobject]@{} }
    $cfg | Add-Member -NotePropertyName Shop -NotePropertyValue $Shop -Force
    $cfg | Add-Member -NotePropertyName UseDarkTheme -NotePropertyValue $global:UseDarkTheme -Force
    $cfg | ConvertTo-Json | Set-Content $configFile
    $global:ActiveShop = $Shop
}

function Load-LiteDbAssembly {
    $dll = Join-Path $ScriptDir 'LiteDB.dll'
    if (-not (Get-Module -ListAvailable -Name LiteDB) -and (Test-Path $dll)) {
        [Reflection.Assembly]::LoadFrom($dll) | Out-Null
    }
}

function Backup-Database {
    if (-not (Test-Path $global:DbPath)) { return }
    $timestamp = Get-Date -Format 'yyyyMMddHHmmss'
    $backup = "$global:DbPath.$timestamp.bak"
    Copy-Item $global:DbPath $backup -ErrorAction SilentlyContinue
}

function Initialize-Database {
    Load-LiteDbAssembly
    $global:DbPath = Get-DatabasePath
    Validate-Database
}

function Validate-Database {
    try {
        Load-LiteDbAssembly
        $db = [LiteDB.LiteDatabase]::new("FileName=$global:DbPath;ReadOnly=true")
        $db.Dispose()
    } catch {
        Restore-LatestBackup
    }
}

function Restore-LatestBackup {
    $pattern = "$global:DbPath.*.bak"
    $latest = Get-ChildItem -Path $pattern | Sort-Object -Property Name -Descending | Select-Object -First 1
    if ($latest) { Copy-Item $latest.FullName $global:DbPath -Force }
}

function Get-Db {
    param([switch]$ReadOnly)
    Load-LiteDbAssembly
    $conn = if ($ReadOnly) { "FileName=$global:DbPath;Mode=ReadOnly" } else { $global:DbPath }
    return [LiteDB.LiteDatabase]::new($conn)
}

function Get-Projects {
    param([string]$Shop)
    $db = Get-Db -ReadOnly
    try {
        $col = $db.GetCollection('projects')
        $col.EnsureIndex('Shop')
        $col.EnsureIndex('Status')
        return $col.Find([LiteDB.Query]::EQ('Shop', $Shop))
    } finally { $db.Dispose() }
}

function Save-Project {
    param($Project)
    Backup-Database
    $db = Get-Db
    try {
        $col = $db.GetCollection('projects')
        $col.Upsert($Project)
    } finally { $db.Dispose() }
}

function Remove-Project {
    param($Project)
    Backup-Database
    $db = Get-Db
    try {
        $col = $db.GetCollection('projects')
        if ($Project.PSObject.Properties['_id']) {
            $col.Delete($Project._id) | Out-Null
        }
    } finally { $db.Dispose() }
}

function Transfer-Project {
    param($Project, [string]$NewShop)
    Backup-Database
    $db = Get-Db
    try {
        $col = $db.GetCollection('projects')
        $Project.Shop = $NewShop
        $col.Upsert($Project) | Out-Null
    } finally { $db.Dispose() }
}

function Sync-ProjectsFromDb {
    param($Collection)
    $Collection.Clear()
    foreach ($p in Get-Projects $global:ActiveShop) {
        if (-not $p.PSObject.Properties['Priority']) { $p | Add-Member -NotePropertyName Priority -NotePropertyValue 'Low' -Force }
        $Collection.Add($p)
    }
    if (Get-Command -Name Apply-StatusOrder -ErrorAction SilentlyContinue) { Apply-StatusOrder }
}

function Get-DistinctShops {
    $db = Get-Db -ReadOnly
    try {
        return $db.GetCollection('projects').Distinct('Shop')
    } finally { $db.Dispose() }
}

function Show-ShopSelection {
    $shops = Get-DistinctShops | Sort-Object
    Add-Type -AssemblyName System.Windows.Forms
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Select Shop'
    $form.StartPosition = 'CenterScreen'
    $combo = New-Object System.Windows.Forms.ComboBox
    $combo.Dock = 'Top'
    $combo.DataSource = $shops
    $form.Controls.Add($combo)
    $ok = New-Object System.Windows.Forms.Button
    $ok.Text = 'OK'
    $ok.Dock = 'Bottom'
    $form.AcceptButton = $ok
    $form.Controls.Add($ok)
    if ($form.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        Set-ActiveShop $combo.SelectedItem
    }
}

function Sync-And-Refresh {
    param($View)
    Sync-ProjectsFromDb $ProjectsCollection
    if ($View) { $View.Refresh() }
}

Export-ModuleMember -Function *
