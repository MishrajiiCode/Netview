param (
    [string]$RepoUrl = ""
)

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  MOVI - Push to GitHub & Release APK/AAB " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# 1. Check if git remote exists
$remote = git remote get-url origin 2>$null
if (-not $remote) {
    if (-not $RepoUrl) {
        $RepoUrl = Read-Host "Enter your GitHub Repository URL (e.g. https://github.com/USERNAME/movi.git)"
    }
    if ($RepoUrl) {
        git remote add origin $RepoUrl
        Write-Host "Added remote origin: $RepoUrl" -ForegroundColor Green
    } else {
        Write-Host "No repository URL provided. Aborting." -ForegroundColor Red
        exit 1
    }
}

# 2. Push code and tag to GitHub
Write-Host "`nPushing main branch and tags to GitHub..." -ForegroundColor Yellow
git push -u origin main --force
git push origin v1.0.0 --force

Write-Host "`nCode and release tag v1.0.0 pushed successfully!" -ForegroundColor Green

# 3. If GitHub CLI is authenticated, create release directly
$ghStatus = gh auth status 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "`nCreating GitHub Release via GitHub CLI..." -ForegroundColor Yellow
    gh release create v1.0.0 `
        release_builds/movi-app-release.apk `
        release_builds/movi-app-release.aab `
        --title "Movi v1.0.0 - Initial Release" `
        --notes "Download the release APK (movi-app-release.apk) or App Bundle (movi-app-release.aab) below."
    Write-Host "GitHub Release created with APK and AAB attached!" -ForegroundColor Green
} else {
    Write-Host "`nNote: GitHub Actions (.github/workflows/release.yml) is triggered automatically by the v1.0.0 tag to build and publish the release on GitHub!" -ForegroundColor Cyan
    Write-Host "Alternatively, you can run 'gh auth login' and re-run this script to upload the local builds immediately." -ForegroundColor Yellow
}
