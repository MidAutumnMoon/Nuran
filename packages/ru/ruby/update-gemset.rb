#!/usr/bin/env ruby

# frozen_string_literal: true

require "tmpdir"

HERE = __dir__

Dir.mktmpdir do |tmpdir|
    ENV["HOME"] = tmpdir

    gemfile = File.join( tmpdir, "Gemfile" )
    gemlock = File.join( tmpdir, "Gemfile.lock" )
    gemset = File.join( HERE, "gemset.nix" )

    File.write gemfile, <<~GEMFILE
        source 'https://rubygems.org'
        gem "colorize"
    GEMFILE

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
