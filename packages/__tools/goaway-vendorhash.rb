#!/usr/bin/env -S ruby

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


abort "Wrong number of command options, requires 2" \
    if ARGV.size != 2

ATTRIBUTE = ARGV.shift
STATEFILE = ARGV.shift

def debug_p( *vs )
    # in 3.4 use "it" instead of "_1"
    vs.each { STDERR.puts _1.inspect } \
        if ENV.has_key? "GV_DEBUG"
end


class VendorHashRecord
    attr_reader :prev, :curr
    def initialize() @prev = nil; @curr = nil end
    def prev=(v) @prev = v.strip end
    def curr=(v) @curr = v.strip end
    def same? = @prev == @curr
    def diff = %{"#{@prev}" → "#{@curr}"}
end

hash_record = VendorHashRecord.new


if File.file? STATEFILE
    hash_record.prev = File.read STATEFILE
end

debug_p hash_record


_, NIX_STDERR, NIX_STATUS = Open3.capture3 <<~RUN
    command nix build --print-build-logs \
        "#{ATTRIBUTE}.goModules"
RUN

debug_p NIX_STDERR, NIX_STATUS


# If nix build do succeed, the already set vendorHash is
# probably correct, so read it to refresh the potentially
# stale old hashes.
if NIX_STATUS.success?

    debug_p "Possibly have vendorHash set correctly"

    hash, err, status = Open3.capture3 <<~RUN
        nix eval --raw "#{ATTRIBUTE}.vendorHash"
    RUN

    debug_p hash, err, status

    abort "Failed to get vendorHash from drv #{ATTRIBUTE}" \
        unless status.success?

    abort "The vendorHash from drv is empty somehow" \
        if hash.empty?

    hash_record.curr = hash

    debug_p hash_record

    if hash_record.same?
        debug_p "Hash unchanged, do nothing"
    else
        debug_p "Write new hash"
        File.write( STATEFILE, hash_record.curr )
        puts hash_record.diff
    end

    exit 0

end


# If nix build failed, things will get trickier
# because nix doesn't signal HOW it failed,
# leaving no other ways beyond searching for patterns
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
    unless SEARCHED_LINES.any? { _1.match? \
        %r{fixed-output derivation.*go-modules\.drv}
    }

hash_record.curr = SEARCHED_LINES.each do |line|
    # hardcoded sha256 here because since epoch no other
    # hash methods have ever been used
    matches = line.match \
        %r{got:.*(?<hash>sha256-[[[:alpha:]][[:digit:]]+\/]{43}=)}

    next if matches.nil?

    debug_p matches

    # there should be only one line with "got: xxx"
    # otherwise screw it mf
    break matches[:hash]
end

debug_p hash_record

if hash_record.same?
    debug_p "New hash equals to old one"
else
    debug_p "Write new hash"
    File.write( STATEFILE, hash_record.curr )
    puts hash_record.diff
end
