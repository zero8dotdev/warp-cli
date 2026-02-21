# Homebrew Auto-Publishing Setup

This guide explains how to set up automatic publishing to Homebrew when you create a release.

## Overview

When you create a GitHub release with a version tag (e.g., `v1.0.0`), a GitHub Actions workflow automatically:

1. Downloads the release tarball
2. Calculates the SHA256 hash
3. Updates the Homebrew formula
4. Commits to the `homebrew-tools` repository
5. Users can then install with `brew install warp`

## Setup Steps

### Step 1: Create `homebrew-tools` Repository

Create a new GitHub repository named `homebrew-tools`:

```bash
github.com/zero8dotdev/homebrew-tools
```

### Step 2: Set Up Repository Structure

In `homebrew-tools`, create this structure:

```
homebrew-tools/
├── Formula/
│   └── warp.rb          # Homebrew formula (see warp.rb in main repo)
├── README.md
└── .github/
    └── workflows/
        └── publish.yml  # This is already in warp-cli repo
```

### Step 3: Copy Files

**In warp-cli repository:**
- `warp.rb` - Homebrew formula template
- `.github/workflows/publish-homebrew.yml` - Auto-publish workflow

**In homebrew-tools repository:**
- Copy the files to their respective locations
- Create `README.md` with installation instructions

### Step 4: Create Personal Access Token

1. Go to GitHub Settings → Developer settings → Personal access tokens
2. Create new token with these scopes:
   - `repo` (full control of private repositories)
   - `workflow` (update GitHub Action workflows)
3. Copy the token

### Step 5: Add Secret to Repository

In `warp-cli` repository settings:

1. Go to Settings → Secrets and variables → Actions
2. Create new secret: `HOMEBREW_TAP_TOKEN`
3. Paste your personal access token

### Step 6: Create a Release

To test the auto-publishing:

```bash
git tag v0.1.0
git push origin v0.1.0
```

Then on GitHub:
1. Go to Releases
2. Create release from tag `v0.1.0`
3. Write release notes
4. Publish release

GitHub Actions will automatically:
- Calculate SHA256
- Update `homebrew-tools/Formula/warp.rb`
- Commit and push to `homebrew-tools`
- Comment on the release with installation instructions

### Step 7: Users Can Install

After the workflow completes, users can install with:

```bash
brew tap zero8dotdev/tools
brew install warp
```

Or update with:

```bash
brew upgrade warp
```

## How It Works

### Release Workflow

```
1. You create release with tag v0.1.0
                    ↓
2. GitHub Actions triggers (on: release published)
                    ↓
3. Downloads source tarball from GitHub
                    ↓
4. Calculates SHA256 of tarball
                    ↓
5. Updates Formula/warp.rb with new version & SHA256
                    ↓
6. Commits to homebrew-tools repo
                    ↓
7. Users can install: brew tap zero8dotdev/warp && brew install warp
```

## Version Management

### Creating a New Release

```bash
# Update version in Cargo.toml
# v0.1.0 → v0.2.0

# Create tag
git tag v0.2.0
git push origin v0.2.0

# Go to GitHub and create release from tag
```

The workflow will automatically handle:
- SHA256 calculation
- Formula update
- Homebrew tap update

## Troubleshooting

### Workflow Failed

Check `.github/workflows/publish-homebrew.yml` logs:
- Is token valid?
- Does homebrew-tools repo exist?
- Is token permissions correct?

### Manual Update

If automated workflow fails, manually update `homebrew-tools`:

```bash
# In homebrew-tools repository
git checkout Formula/warp.rb
# Update url to new version
# Update sha256 with output of: shasum -a 256 warp-v0.2.0.tar.gz
git add Formula/warp.rb
git commit -m "chore: bump warp to v0.2.0"
git push
```

## Future: homebrew-core

Once the project is more mature, you can submit to official Homebrew:

```bash
# Fork homebrew-core
# Create new formula: warp.rb
# Submit pull request

# Users can then install with:
brew install warp  # No tap needed!
```

## Files Included

- **warp.rb** - Homebrew formula template (in warp-cli repo)
- **.github/workflows/publish-homebrew.yml** - GitHub Actions workflow (in warp-cli repo)
- **HOMEBREW_SETUP.md** - This guide (in warp-cli repo)

## Quick Reference

### Installation Command (for users)
```bash
brew tap zero8dotdev/tools
brew install warp
```

### Update Command (for users)
```bash
brew upgrade warp
```

### Creating a New Release (for you)
```bash
git tag v1.0.0
git push origin v1.0.0
# Then create release on GitHub UI
```

## Next Steps

1. ✅ Files are ready in this repository
2. Create `homebrew-tools` repository on GitHub
3. Copy files to `homebrew-tools`
4. Set up `HOMEBREW_TAP_TOKEN` secret
5. Create first release
6. Test installation with `brew tap zero8dotdev/warp && brew install warp`

That's it! You now have automated Homebrew publishing! 🎉
