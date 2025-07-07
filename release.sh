#!/bin/bash

# 🔥 Automated Release Script for reqbuddy
# Usage: ./release.sh 0.1.7 "Short description for changelog and GitHub release"

#Exit when error occured
set -e

VERSION="$1"
MESSAGE="$2"
TAG="v$VERSION"

if [ -z "$VERSION" ] || [ -z "$MESSAGE" ]; then
  echo "❌ Usage: ./release.sh <version> \"<message>\""
  echo "Example: ./release.sh 0.1.7 \"Add CLI command and fix deduplication\""
  exit 1
fi

# Ensure gh CLI is available
if ! command -v gh &> /dev/null; then
  echo "❌ GitHub CLI (gh) not found. Install from https://cli.github.com/"
  exit 1
fi

echo "📦 Releasing version $VERSION ..."

# --- 🛠 Step 1: Update pyproject.toml ---
sed -i "s/^version = \".*\"/version = \"$VERSION\"/" pyproject.toml
echo "✅ Updated pyproject.toml to $VERSION"

# --- 📝 Step 2: Update CHANGELOG.md ---

if [ ! -f CHANGELOG.md ]; then
  echo "# 📦 Changelog" > CHANGELOG.md
fi

DATE=$(date +%Y-%m-%d)
echo -e "\n## [$VERSION] - $DATE\n- $MESSAGE" >> CHANGELOG.md
echo "✅ Updated CHANGELOG.md"

# --- 💾 Step 3: Commit the changes ---
git add pyproject.toml CHANGELOG.md
git commit -m "🔖 Prepare release $TAG"
echo "✅ Committed release changes"

# --- 🏷 Step 4: Tag the release ---
git tag $TAG
echo "✅ Created git tag $TAG"

# --- ⬆️ Step 5: Push everything ---
git push origin main
git push origin $TAG
echo "🚀 Pushed main and tag to GitHub"

# --- 📦 Step 6: Create GitHub Release via CLI ---
gh release create $TAG \
  --title "$TAG" \
  --notes "$MESSAGE" \
  --verify-tag
echo "✅ GitHub Release created"

# --- ⏳ Step 7: Wait for PyPI confirmation (polling) ---
echo "⏳ Waiting for PyPI upload to confirm..."

sleep 15  # Give GitHub Action time to start


PYPI_CHECK_URL="https://pypi.org/pypi/reqbuddy/json"
RETRIES=10
FOUND="false"

for i in $(seq 1 $RETRIES); do
  echo "🔍 Checking PyPI (attempt $i)..."

  # Use jq for accurate JSON parsing
  VERSION_FOUND=$(curl -s "$PYPI_CHECK_URL" | jq -r --arg VERSION "$VERSION" '.releases[$VERSION] | if . then $VERSION else empty end')

  echo "🔍 Version found: '$VERSION_FOUND'"

  if [[ "$VERSION_FOUND" == "$VERSION" ]]; then
    echo "✅ Match: $VERSION_FOUND == $VERSION"
    FOUND="true"
    break
  else
    echo "❌ No match: $VERSION_FOUND != $VERSION"
  fi

  sleep 10
done

if [[ "$FOUND" == "true" ]]; then
  echo "🎉 PyPI upload confirmed! Version $VERSION is live at:"
  echo "🔗 https://pypi.org/project/reqbuddy/$VERSION/"
else
  echo "⚠️ PyPI upload not detected after $((RETRIES * 10)) seconds. Check GitHub Actions:"
  echo "🔗 https://github.com/AstinOfficial/reqbuddy/actions"
fi