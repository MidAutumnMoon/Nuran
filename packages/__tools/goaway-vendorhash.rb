#!/usr/bin/env -S ruby

# frozen_string_literal: true

# This is what you get for choosing a braindead language
# and its ecosystem.
#
# $this ATTRIBUTE STATEFILE
#
# ATTRIBUTE: something to build, doesn't care about it too much
# as long as it's a go application and has proxyVendor=true set
#
# STATEFILE: captured vendorhash will be compared from
# and written into this file

require "open3"
require 'fileutils'


abort "Wrong number of command options, requires 2" \
    if ARGV.size != 2

ATTRIBUTE = ARGV.shift
STATEFILE = ARGV.shift

def debug_p( *values )
    # in 3.4 use "it" instead of "_1"
    values.each { warn _1.inspect } if ENV.key? "GV_DEBUG"
end


# Holds prev and curr hash, alongside with some
# helper methods.
class VendorHashRecord
    attr_reader :prev, :curr

    def initialize
        @prev = nil; @curr = nil
    end

    def prev=( value )
        @prev = value.strip
    end

    def curr=( value )
        @curr = value.strip
    end

    def same? = @prev == @curr

    def diff = %("#{@prev}" → "#{@curr}")
end

hash_record = VendorHashRecord.new


if not File.file? STATEFILE
    FileUtils.mkdir_p( File.dirname( STATEFILE ) )
    FileUtils.touch STATEFILE
end

hash_record.prev = File.read STATEFILE

debug_p hash_record

# Reset the vendorHash so that nix will do a rebuild
File.write STATEFILE, ""


_, NIX_STDERR, NIX_STATUS = Open3.capture3 <<~RUN
    command nix build --print-build-logs \
        "#{ATTRIBUTE}.goModules"
RUN

debug_p NIX_STDERR, NIX_STATUS

abort "Why succeed?" if NIX_STATUS.success?


# Because nix doesn't signal HOW it failed,
# it leaves no other ways beyond searching for patterns
# in the output texts, all sorts of Unix BSs.
#
# The following pattern will be searched for on
# last 5 lines from the output:
#
# hash mismatch in fixed-output derivation '/nix/store/what-go-modules.drv'
#       specified: whatwhat
#         got:     sha256-something
#                 ^^^^^^^^^^^^^^^^^--- search & capture this

SEARCHED_LINES = NIX_STDERR.lines.last 5

debug_p SEARCHED_LINES


abort "The thing that is hard to describe is not go-modules" \
    unless SEARCHED_LINES.any? do
        _1.match?( /fixed-output derivation.*go-modules\.drv/ )
    end

hash_record.curr = SEARCHED_LINES.each do |line|
    # hardcoded sha256 here because since epoch no other
    # hash methods have ever been used
    matches = line.match \
        %r{got:.*(?<hash>sha256-[[[:alpha:]][[:digit:]]+/]{43}=)}

    next if matches.nil?

    debug_p matches

    # there should be only one line with "got: xxx"
    # otherwise screw it mf
    break matches[:hash]
end

debug_p hash_record

if hash_record.same?
    debug_p "New hash equals to old one"
    File.write( STATEFILE, hash_record.prev )
else
    debug_p "Write new hash"
    File.write( STATEFILE, hash_record.curr )
    puts hash_record.diff
end
