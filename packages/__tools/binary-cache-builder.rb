#!/usr/bin/env -S ruby

# frozen_string_literal: true

# $this MANIFEST SUBJECT
#
# MANIFEST: a nix file evaluating to a an attrset, with each
# attribute knwon as s SUBJECT
#
# SUBJECT: an attribute in MANIFEST, directly passed to "nix build".

abort "Wrong number of command options, need 2" \
    if ARGV.size != 2

MANIFEST = ARGV.shift
SUBJECT = ARGV.shift

abort %(Manifest "#{MANIFEST}" is not a file) \
    unless File.file? MANIFEST

system <<~SCRIPT or abort "Failed to run nix build"
    nix build --file "#{MANIFEST}" \
        "#{SUBJECT}" \
        --print-build-logs \
        --option narinfo-cache-negative-ttl 0 \
        --option keep-going true \
        --option max-jobs 3
SCRIPT
