# Nuran

There is no sanity.

## Use Nuran's Binary Cache

Nuran's binary cache is provided by [Cachix](https://www.cachix.org/),
however migrating to [Garnix](https://garnix.io/) is on the roadmap somewhere.

1. Add `https://nuirrce.cachix.org` to substituter list
2. Add pubkey `nuirrce.cachix.org-1:KQWa6ZfDkMPXeDiUpmyDhNw4CmgybPyeVklmi/1Rtqk=`

## Notes on Setup GitHub Actions

### Necessary Permission
1. Find `Actions/General` in Settings.
2. Select `Read and write permissions` under Workflow permissions.
3. Enable `Allow Github Actions to create...pull requests`.

### Setup Cachix
1. Obtain the token from Cachix dashboard.
2. Put the token in a secret named `CACHIX_AUTH_TOKEN`.
