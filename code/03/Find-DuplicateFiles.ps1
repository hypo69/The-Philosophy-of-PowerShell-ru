function Find-DuplicateFiles {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path
    )
    
    Get-ChildItem $Path -File -Recurse -ErrorAction SilentlyContinue | 
        Group-Object Name, Length | 
        Where-Object { $_.Count -gt 1 } | 
        ForEach-Object {

            Write-Host "Найдены дубликаты: $($_.Name)" -ForegroundColor Yellow
            $_.Group | Select-Object FullName, Length, LastWriteTime
        }
}
