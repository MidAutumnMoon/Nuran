# Nuran

There is no sanity.


## Steps to provision GitHub Action

1. Action permission
    1. Find Action/Runners under Settings
    2. Find "Workflow permissions"
    3. Allow read/write
    4. Toggle "...Action to create...pull requests"

2. Cachix
    1. Obtain auth token from Cachix dashboard
    2. Create a secret named `CACHIX_AUTH_TOKEN` with that token as content
