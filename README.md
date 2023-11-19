# Nuran

There is no sanity.

## Notes to setup GitHub Actions environment

### Permission
1. Find `Actions/General` in Settings.
2. Select `Read and write permissions` under Workflow permissions.
3. Enable `Allow Github Actions to create...pull requests`.

### Cachix
1. Obtain the token from Cachix dashboard.
2. Put the token in a secret named `CACHIX_AUTH_TOKEN`.
