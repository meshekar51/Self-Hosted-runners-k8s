# Add this integration to your GitHub repository

Target repository: `meshekar51/go-web-app-devops`.

Extract the ZIP first. Upload the actual files, rather than only the ZIP, so GitHub renders the documentation and recognises the workflow.

## File placement

| Bundle file | Recommended location in an existing app repository |
|---|---|
| `README.md` | `docs/arc-eks/README.md` |
| `UPLOAD-GUIDE.md` | `docs/arc-eks/UPLOAD-GUIDE.md` |
| `k8s/arc/namespaces.yaml` | `k8s/arc/namespaces.yaml` |
| `k8s/arc/runner-values.yaml` | `k8s/arc/runner-values.yaml` |
| `scripts/New-ArcGitHubSecret.ps1` | `scripts/New-ArcGitHubSecret.ps1` |
| `.github/workflows/arc-scale-test.yml` | `.github/workflows/arc-scale-test.yml` |
| `.gitignore` | Merge patterns into your existing `.gitignore` |

For a dedicated integration repository, use the bundle layout directly with its README at the root. For an existing application repository, preserve its current README and store this guide under `docs/arc-eks/`.

When relocating the guide, change its relative links from `k8s/arc/` to `../../k8s/arc/`, from `scripts/` to `../../scripts/`, and from `.github/` to `../../.github/`. Commands in the guide still run from the repository root. The PowerShell option below performs these link edits for you.

## Option A: GitHub website

1. Open the repository, choose a new branch such as `docs/arc-eks-integration`, and select **Add file → Create new file**.
2. Enter each destination path from the table and paste that file's contents. GitHub creates the parent folders as needed.
3. Adjust the README relative links as described above if placing it under `docs/arc-eks/`.
4. Add a link to the application's existing README: `[GitHub Actions runners on EKS](docs/arc-eks/README.md)`.
5. Review the diff, open a pull request, and merge through the repository's normal process.
6. Once the workflow reaches the default branch, open **Actions → ARC - 10 Runner Scaling Test → Run workflow**.

The `.github` folder starts with a dot. Its exact spelling and location at the repository root are required. A workflow stored only under `docs/` is not an active workflow.

## Option B: Windows PowerShell and Git

Use a local clone with no unrelated changes. If needed, install Git through your approved method, clone the repository, and enter its root:

```powershell
git clone https://github.com/meshekar51/go-web-app-devops.git
Set-Location .\go-web-app-devops
git status --short
```

The `.git` suffix is appropriate for `git clone`; omit it in ARC's `githubConfigUrl`.

Create a branch and specify the extracted bundle folder:

```powershell
git switch -c docs/arc-eks-integration
$ArcBundle = Read-Host 'Enter the full path of the extracted arc-eks-integration folder'
if (-not (Test-Path (Join-Path $ArcBundle 'README.md'))) {
    throw 'Bundle README not found. Check the folder path.'
}
```

Review destination files before copying. If an integration file already exists, compare and merge it instead of blindly overwriting it. The block below stops if any destination exists:

```powershell
$ArcDestinations = @(
    'docs/arc-eks/README.md',
    'docs/arc-eks/UPLOAD-GUIDE.md',
    'k8s/arc/namespaces.yaml',
    'k8s/arc/runner-values.yaml',
    'scripts/New-ArcGitHubSecret.ps1',
    '.github/workflows/arc-scale-test.yml'
)
foreach ($ArcDestination in $ArcDestinations) {
    if (Test-Path $ArcDestination) {
        throw "Already exists: $ArcDestination. Compare and merge this file first."
    }
}

New-Item -ItemType Directory -Force -Path .\docs\arc-eks, .\k8s\arc, .\scripts, .\.github\workflows | Out-Null
Copy-Item (Join-Path $ArcBundle 'k8s/arc/namespaces.yaml') .\k8s\arc\
Copy-Item (Join-Path $ArcBundle 'k8s/arc/runner-values.yaml') .\k8s\arc\
Copy-Item (Join-Path $ArcBundle 'scripts/New-ArcGitHubSecret.ps1') .\scripts\
Copy-Item (Join-Path $ArcBundle '.github/workflows/arc-scale-test.yml') .\.github\workflows\
Copy-Item (Join-Path $ArcBundle 'UPLOAD-GUIDE.md') .\docs\arc-eks\

$ArcReadme = Get-Content (Join-Path $ArcBundle 'README.md') -Raw
$ArcReadme = $ArcReadme.Replace('](k8s/arc/', '](../../k8s/arc/')
$ArcReadme = $ArcReadme.Replace('](scripts/', '](../../scripts/')
$ArcReadme = $ArcReadme.Replace('](.github/', '](../../.github/')
$ArcReadme | Set-Content .\docs\arc-eks\README.md -Encoding utf8
```

Merge useful ignore patterns from the bundle into the existing `.gitignore`. Add the documentation link to your existing application README without replacing its contents. Review and stage only the intended files:

```powershell
git status --short
git diff
git add docs/arc-eks/README.md docs/arc-eks/UPLOAD-GUIDE.md k8s/arc/namespaces.yaml k8s/arc/runner-values.yaml scripts/New-ArcGitHubSecret.ps1 .github/workflows/arc-scale-test.yml
# If you edited these files, stage them separately:
# git add README.md .gitignore
git diff --cached --stat
git diff --cached
```

Confirm no credentials are staged, then commit and push the branch:

```powershell
git commit -m "Document ARC integration with EKS and add ten-runner test"
git push -u origin docs/arc-eks-integration
```

Open a pull request in GitHub and merge through the normal review process. Uploading these files does not install ARC; follow the README for cluster changes. The workflow runs only when manually triggered after it is available on the default branch.
