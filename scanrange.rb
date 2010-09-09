#!/usr/bin/env ruby

require 'getoptlong'


@options = GetoptLong.new(
    ['--start', GetoptLong::REQUIRED_ARGUMENT],
    ['--end', GetoptLong::REQUIRED_ARGUMENT]
)
$scan_range = [Date.today - 1, Date.today - 1]
$SHORT_DATE_RE = '(?:[0-9]{4})(?:0[1-9]|1[0-2])(?:[0-2][0-9]|3[01])'
$LONG_DATE_RE = '(?:[0-9]{4})-(?:0[1-9]|1[0-2])-(?:[0-2][0-9]|3[01])'
$SHORT_DATE_F = $DATEF
$LONG_DATE_F = '%Y-%m-%d'

def parse_args
    @options.each do |opt, arg|
        case opt
        when '--start'
            if arg !~ /(?:#{$SHORT_DATE_RE}|#{$LONG_DATE_RE})/
                $stderr.puts "invalid date `#{arg}'; " +
                        "must be of format `#{$LONG_DATE_F}' " +
                        "or `#{$SHORT_DATE_F}'"
                abort
            else
                temp = Date.strptime(arg,
                        if arg =~ /#{$LONG_DATE_RE}/ then $LONG_DATE_F
                        else $SHORT_DATE_F end)
                if temp > $scan_range[1]
                    $stderr.puts "invalid start date `#{arg}'; " +
                            "must be before end date " +
                            $scan_range[1].strftime($LONG_DATE_F)
                elsif temp > (Date.today - 1)
                    $stderr.puts "time travel mode is not implemented! " +
                            "do not start scanning from future dates!"
                else
                    $scan_range[0] = if temp < (Date.today - 1) then temp
                    else (Date.today - 1) end
                end
            end
        when '--end'
            if arg !~ /(?:#{$SHORT_DATE_RE}|#{$LONG_DATE_RE})/
                $stderr.puts "invalid date `#{arg}'; " +
                        "must be of format `#{$LONG_DATE_F}' " +
                        "or `#{$SHORT_DATE_F}'"
                abort
            else
                temp = Date.strptime(arg,
                        if arg =~ /#{$LONG_DATE_RE}/ then $LONG_DATE_F
                        else $SHORT_DATE_F end)
                if temp < $scan_range[0]
                    $stderr.puts "invalid end date `#{arg}'; " +
                            "must be after start date " +
                            $scan_range[0].strftime($LONG_DATE_F)
                    abort
                elsif temp > (Date.today - 1) then
                    $stderr.puts "time travel mode is not implemented! " +
                            "assuming stop scan for changes at today."
                    $scan_range[1] = (Date.today - 1)
                else
                    $scan_range[1] = temp
                end
            end
        end #case opt
    end #options.each
end
