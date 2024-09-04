#!/usr/bin/env ruby

# frozen_string_literal: true

require "English"
require "tmpdir"
require "pathname"

abort "bundix not found" \
    unless system "bundix --version", out: File::NULL


HERE = Pathname.new __dir__

GEMFILE = <<~GEM
    source 'https://rubygems.org'
    gem "amazing_print"
    gem "async"
    gem "reinbow"
    gem "irb"
GEM

GEMFILE_DEV = <<~GEM
    source 'https://rubygems.org'
    gem "rubocop"
GEM

# Maps the content of Gemfile to the filename
# of output gemset.nix
MAPPING = {
    GEMFILE => "gemset.nix",
    GEMFILE_DEV => "gemset-dev.nix",
}.freeze


class Pathname
    alias to_str to_path
end


MAPPING.each_pair do |gemfile_content, gemset_name|

    tmpdir = Pathname.new( Dir.mktmpdir )

    ENV["HOME"] = tmpdir
    ENV["XDG_CACHE_HOME"] = tmpdir / "cache"
    ENV["BUNDLE_USER_CONFIG"] = tmpdir / "bundle.cfg"
    ENV["BUNDLE_USER_CACHE"] = tmpdir / "bundle.cache"
    ENV["BUNDLE_USER_PLUGIN"] = tmpdir / "bundle.data"

    gemfile = tmpdir / "Gemfile"
    gemfile.write gemfile_content

    gemlock = tmpdir / "Gemfile.lock"

    gemset = HERE / gemset_name

    Dir.chdir tmpdir do
        system "bundle lock --verbose --lockfile=#{gemlock}"
        abort "Failed to run bundle lock" if not $CHILD_STATUS
    end

    system <<~RUN
        bundix \
            --gemfile "#{gemfile}" \
            --lockfile "#{gemlock}" \
            --gemset "#{gemset}"
    RUN

    abort "Failed to run bundix" if not $CHILD_STATUS

    puts

end
