#!/usr/bin/env ruby

# frozen_string_literal: true

require "tmpdir"
require "pathname"

HERE = Pathname.new __dir__

GEMFILE = <<~FILE
    source 'https://rubygems.org'
    gem "amazing_print"
    gem "async"
    gem "console"
    gem "irb"
    gem "rainbow"
    gem "rubocop"
FILE

abort "bundix not found" \
    unless system "bundix --version", out: File::NULL

class Pathname
    alias to_str to_s
end

Dir.mktmpdir do |t|
    tmpdir = Pathname.new t

    ENV["HOME"] = tmpdir
    ENV["XDG_CACHE_HOME"] = tmpdir / "cache"
    ENV["BUNDLE_USER_CONFIG"] = tmpdir / "bundle.cfg"
    ENV["BUNDLE_USER_CACHE"] = tmpdir / "bundle.cache"
    ENV["BUNDLE_USER_PLUGIN"] = tmpdir / "bundle.data"

    gemfile = tmpdir / "Gemfile"
    gemlock = tmpdir / "Gemfile.lock"
    gemset = HERE / "gemset.nix"

    File.write gemfile, GEMFILE

    Dir.chdir tmpdir do
        system "bundle lock --verbose --lockfile=#{gemlock}"
    end

    system <<~RUN
        bundix \
            --gemfile "#{gemfile}" \
            --lockfile "#{gemlock}" \
            --gemset "#{gemset}"
    RUN
end
