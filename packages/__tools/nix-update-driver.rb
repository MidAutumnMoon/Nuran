#!/usr/bin/env ruby

# frozen_string_literal: true

# ./nix-update-driver.rb REPORT
#
# REPORT: path of file for writing update reports to

require "English"
require "open3"
require "reinbow"
require "stringio"

using Reinbow

#
# Setup
#

abort "nix-update not found" \
    unless system( "nix-update --help", out: File::NULL )

abort "wrong number of options, expecting 1" \
    unless ARGV.size == 1

REPORT = File.new( ARGV.pop, File::RDWR | File::TRUNC | File::CREAT )

#
# Attributes of packages to be updated
#

PACKAGES = <<~ATTR
    shadowsocks_teapot
ATTR

#
# Run nix-update
#

PROJECT_ROOT = lambda do
    toplevel = `git rev-parse --show-toplevel`
    abort "Failed to get toplevel using git" \
        unless $CHILD_STATUS.success? && !toplevel.empty?
    warn "Change pwd to #{toplevel}".yellow
    Dir.chdir toplevel.strip
end.call


REPORT.puts <<~MARKDOWN
    ## nix-update reports
MARKDOWN

PACKAGES.lines( chomp: true ).each do |package|

    warn "Run nix-update on #{package}".yellow

    report_content = StringIO.new

    Open3.popen2e <<~CMD do |_, outs, waiter|
        nix-update --flake "#{package}"
    CMD
        outs.each_line( chomp: true ) do |line|
            warn line
            report_content.puts "#{line}\n"
        end

        abort "Failed to run nix-update on #{package}" \
            unless waiter.value.success?
    end

    REPORT.puts <<~MARKDOWN
        ### #{package}
        <details>
            <summary>nix-update output</summary>
            <pre><code>
                #{report_content.string}
            </code></pre>
        </details>
    MARKDOWN

end

__END__

shadowsocks_teapot
