#!/usr/bin/env ruby

# frozen_string_literal: true

# ./nix-update-driver.rb
#
# Environment Variables

require "English"
require "open3"

#
# Sanity checks
#

abort "nix-update not found" \
    unless system( "nix-update --help", out: File::NULL )

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
    warn "Change pwd to #{toplevel}"
    Dir.chdir toplevel.strip
end.call


puts <<~MARKDOWN
    ## nix-update reports
MARKDOWN

PACKAGES.lines.each do |name|

    name.strip!

    warn "Run nix-update on #{name}"

    output, status = Open3.capture2e <<~RUN
        nix-update --flake "#{name}"
    RUN

    abort "Failed to run nix-update on #{name}" \
        unless status.success?

    puts <<~MARKDOWN
        ### #{name}
        <details>
            <summary>nix-update output</summary>
            <pre><code>#{output}</code></pre>
        </details>
    MARKDOWN

end

__END__

shadowsocks_teapot
