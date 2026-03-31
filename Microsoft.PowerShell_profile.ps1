function New-SSHTunnel {
    param(
        [Parameter(Mandatory)][ValidateRange(1,65535)][int]$Port,
        [Parameter(Mandatory)][string]$Server,
        [string]$User = "arthur"
    )

    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8

    $process = Start-Process -FilePath "ssh" `
        -ArgumentList "-N -v -o ExitOnForwardFailure=yes -o ServerAliveInterval=30 -o ServerAliveCountMax=3 -L ${Port}:localhost:${Port} ${User}@${Server}" `
        -PassThru `
        -WindowStyle Minimized

    $pidFile = "$env:TEMP\ssh_tunnel_$Port.pid"
    $process.Id | Out-File -FilePath $pidFile -Encoding UTF8

    Write-Host "[SSH Tunnel] Tunnel demarre sur le port $Port (PID: $($process.Id))" -ForegroundColor Green
}

function Stop-SSHTunnel {
    param([Parameter(Mandatory)][int]$Port)

    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8

    $pidFile = "$env:TEMP\ssh_tunnel_$Port.pid"

    if (Test-Path $pidFile) {
        $savedPid = Get-Content $pidFile -Encoding UTF8
        $proc = Get-Process -Id $savedPid -ErrorAction SilentlyContinue
        if ($proc) {
            Stop-Process -Id $savedPid -Force
            Write-Host "[SSH Tunnel] Tunnel port $Port arrete (PID $savedPid)." -ForegroundColor Green
        } else {
            Write-Host "[SSH Tunnel] Processus deja mort." -ForegroundColor Yellow
        }
        Remove-Item $pidFile -ErrorAction SilentlyContinue
    } else {
        Write-Host "[SSH Tunnel] Aucun tunnel trouve sur le port $Port." -ForegroundColor Yellow
    }
}

function Get-SSHTunnels {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8

    $pidFiles = Get-ChildItem "$env:TEMP\ssh_tunnel_*.pid" -ErrorAction SilentlyContinue

    if (-not $pidFiles) {
        Write-Host "Aucun tunnel SSH actif." -ForegroundColor Yellow
        return
    }

    $pidFiles | ForEach-Object {
        $port     = $_.Name -replace "ssh_tunnel_(\d+)\.pid", '$1'
        $savedPid = Get-Content $_.FullName -Encoding UTF8
        $proc     = Get-Process -Id $savedPid -ErrorAction SilentlyContinue

        if ($proc) {
            Write-Host "[Port $port] PID $savedPid  --  En cours  --  demarre $($proc.StartTime)" -ForegroundColor Green
        } else {
            Write-Host "[Port $port] PID $savedPid  --  Mort (fichier orphelin)" -ForegroundColor Red
            Remove-Item $_.FullName
        }
    }
}

function Find-SSHTunnel {
    param([Parameter(Mandatory)][int]$Port)

    $pidFile = "$env:TEMP\ssh_tunnel_$Port.pid"

    if (-not (Test-Path $pidFile)) {
        Write-Host "Aucun tunnel trouve pour le port $Port." -ForegroundColor Red
        return $null
    }

    $savedPid = Get-Content $pidFile -Encoding UTF8
    $proc = Get-Process -Id $savedPid -ErrorAction SilentlyContinue

    if (-not $proc) {
        Write-Host "Le tunnel port $Port existait (PID $savedPid) mais le processus est mort." -ForegroundColor Red
        Remove-Item $pidFile
        return $null
    }

    return $proc
}