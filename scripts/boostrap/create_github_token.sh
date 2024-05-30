#!/bin/bash

GITHUB_REPO="Cobollatin/jw-semantic-searcher" # The format is: user/repo
GITHUB_TOKEN=$(gh auth status --show-token)

gh secret set TF_GITHUB_TOKEN -b"$GITHUB_TOKEN" --repo $GITHUB_REPO

echo "GitHub token created successfully"