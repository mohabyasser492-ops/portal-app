$ErrorActionPreference = "Stop"

$solutionPath = ".\PortalApp.sln"

if (-not (Test-Path $solutionPath)) {
    dotnet new sln -n PortalApp
}

$projects = Get-ChildItem `
    -Path ".\src", ".\tests" `
    -Filter "*.csproj" `
    -Recurse

$existingProjects = dotnet sln $solutionPath list

foreach ($project in $projects) {
    $relativePath = $project.FullName.Replace(
        (Get-Location).Path + "\",
        ""
    )

    $relativePathWithForwardSlashes = $relativePath.Replace("\", "/")

    if (
        $existingProjects -notcontains $relativePath -and
        $existingProjects -notcontains $relativePathWithForwardSlashes
    ) {
        dotnet sln $solutionPath add $project.FullName
    }
}

Write-Host ""
Write-Host "Portal App solution is ready."
dotnet sln $solutionPath list