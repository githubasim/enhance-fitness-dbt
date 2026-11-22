function Run($cmd) {
    Write-Host ">> $cmd"
    Invoke-Expression $cmd
    if ($LASTEXITCODE -ne 0) { Write-Error "Failed: $cmd"; exit 1 }
}

Run "python generator\generate_reference.py"
Run "python generator\generate_transactions.py"
Run "python generator\load_raw.py"
Run "dbt source freshness"
Run "dbt build"