#!/usr/bin/env ruby

# frozen_string_literal: true

# ./nix-update-driver.rb MANIFEST REPORT
#
# MANIFEST: path of a .rb file contains array of packages that needs to be updated
# REPORT: path of file for writing update reports to

require "English"
require "reinbow"
require "stringio"
require "tempfile"
require "shellwords"

require "async"
require "async/barrier"
require "async/semaphore"

using Reinbow

#
# Setup
#

abort "nix-update not found" \
    unless system( "nix-update --help", out: File::NULL )

abort "wrong number of options, expecting 2" \
    unless ARGV.size == 2

MANIFEST = File.read( ARGV.shift )
REPORT = File.new( ARGV.shift, File::RDWR | File::TRUNC | File::CREAT )

# Switch the pwd to the toplevel of git repo, which also contains flake.nix
# in this case. Otherwise nix-update will complain about unable to find flake.nix.
lambda do
    toplevel = `git rev-parse --show-toplevel`
    abort "Failed to get toplevel using git" \
        unless $CHILD_STATUS.success? && !toplevel.empty?
    warn "Change pwd to #{toplevel}".yellow
    Dir.chdir toplevel.strip
end.call

#
# Attributes of packages to be updated
#

# rubocop:disable Security/Eval
PACKAGES = eval MANIFEST
# rubocop:enable Security/Eval

#
# Run nix-update
#

barrier = Async::Barrier.new
semaphore = Async::Semaphore.new( 6, parent: barrier )

REPORT.puts <<~MARKDOWN
    ## nix-update reports
MARKDOWN


# rubocop:disable Layout/MultilineBlockLayout
# rubocop:disable Layout/IndentationWidth
# rubocop:disable Layout/RescueEnsureAlignment
# rubocop:disable Layout/EmptyLinesAroundExceptionHandlingKeywords

Sync do; PACKAGES.map do |package|
    warn "Run nix-update on #{package}".yellow

    attribute = nil
    extra_opts = []

    case package
    in String
        attribute = package
    in { attr:, branch: true }
        attribute = attr
        extra_opts << "--version=branch"
    end

    semaphore.async do

        logfile = Tempfile.create

        status = system <<~CMD
            nix-update \
                #{extra_opts.shelljoin} \
                --write-commit-message "#{logfile.path}" \
                --flake "#{attribute}"
        CMD

        unless status
            logfile.close
            abort "Failed to run nix-update on #{attribute}"
        end

        # This first of commit message from nix-update is package's name
        # with version bumps after it. This adds a Markdown heading before it.
        REPORT.puts "### #{logfile.read}"

    ensure
        logfile.close
    end
end.map( &:wait ); ensure

    barrier.stop

end

# rubocop:enable Layout/MultilineBlockLayout
# rubocop:enable Layout/IndentationWidth
# rubocop:enable Layout/RescueEnsureAlignment
# rubocop:enable Layout/EmptyLinesAroundExceptionHandlingKeywords
