name: Syncing with Upstream

on:
  schedule:
    - cron: "0 0 * * 0"  # Runs every Sunday at 00:00 UTC
  workflow_dispatch:      # Allow manual trigger from GitHub Actions UI

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          persist-credentials: false
          fetch-depth: 0

      - name: Add and fetch upstream
        run: |
          git remote add upstream https://github.com/ublue-os/image-template.git || true
          git fetch upstream

      - name: Rebase onto upstream/main
        run: |
          git checkout main
          git rebase upstream/main || true

      - name: Push changes to origin
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          git push origin main --force-with-lease

