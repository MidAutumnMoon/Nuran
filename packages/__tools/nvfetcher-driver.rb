#!/usr/bin/env ruby

# $this MANIFEST OUTPUTDIR GH_TOKEN
#
# MANIFEST: the toml file feeded to nvfetcher
# OUTPUTDIR: where nvfetcher puts results
# GH_TOKEN: Github token for avoiding ratelimiting

require "tempfile"

abort "Wrong number of command options, requires 3" \
    if ARGV.size != 3

MANIFEST = ARGV.shift
OUTPUTDIR = ARGV.shift
GH_TOKEN = ARGV.shift

abort "nvfetcher not found" \
    unless -> { `which nvfetcher 2> /dev/null`; $?.success? }.call


# Remove stale files

system <<~RUN
    find #{OUTPUTDIR} -mindepth 1 ! -name "generated.*" -delete
RUN


# Generate nvfetcher keyfile with github token

KEYFILE = Tempfile.new %w{nvfetcher .toml}

KEYFILE.write <<~CFG
    [keys]
    github = "#{GH_TOKEN}"
CFG

puts KEYFILE.path


# Call nvfetcher

system <<~RUN
    nvfetcher \
        --config "#{MANIFEST}" \
        --build-dir "#{OUTPUTDIR}" \
        --keyfile "#{KEYFILE}" \
        --retry 8 -j 8
RUN
