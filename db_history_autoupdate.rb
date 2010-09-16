#!/usr/bin/env ruby

require 'date'
require 'tempfile'

require 'rubygems'
require 'active_record'

require 'build_entry'
require 'build_query'
require 'content_for'
require 'scanrange'


$DATEF = '%Y-%m-%d'
$SHORT_DATE_F = '%Y%m%d'


parse_args()


@database_configuration = {}
File.open('database.conf', 'r') do |f|
    f.each do |line|
        line =~ /^(.+):(.+)$/
        @database_configuration[$1] = $2
    end
end


ActiveRecord::Base.establish_connection(@database_configuration)
class Document < ActiveRecord::Base; end
class Event < ActiveRecord::Base; end
class Submission < ActiveRecord::Base; end


docs_table = "cchdo.documents"
evts_table = "cchdo.events"
subs_table = "cchdo.submissions"
docs_params = selectionize(
        %w{ExpoCode FileName LastModified}, docs_table)
evts_params = selectionize(
        %w{ExpoCode First_Name LastName Note Date_Entered}, evts_table)
subs_params = selectionize(
        %w{ExpoCode file name institute notes submission_date},
        subs_table)
docs_query = find_by_date(docs_params, docs_table, "LastModified")
evts_query = find_by_date(evts_params, evts_table, "Date_Entered")
subs_query = find_by_date(subs_params, subs_table, "submission_date")


@documents = Document.find_by_sql(docs_query)
@events = Event.find_by_sql(evts_query)
@submissions = Submission.find_by_sql(subs_query)


@entries = []
@used_expos = []


def docs_for (date)
    @documents.collect {|doc|
        if doc.LastModified.strftime(fmt=$DATEF) == date.to_s then doc
        else nil end
    }.compact
end
def evts_for (date, expocode)
    @events.collect {|evt|
        if evt.Date_Entered.to_s == date.to_s and evt.ExpoCode == expocode
            evt
        else nil end
    }.compact
end
def no_doc_evts_for (date)
    @events.collect {|evt|
        if (evt.Date_Entered.to_s == date.to_s and
                !@used_expos.include? evt.ExpoCode)
            evt
        else nil end
    }.compact
end
def subs_for (date)
    @submissions.collect {|sub|
        if sub.submission_date.to_s == date.to_s then sub
        else nil end
    }.compact
end


$scan_range[1].downto($scan_range[0]) do |date|
    unless (docs = docs_for(date)).empty?
        docs.each do |doc|
            @used_expos << doc.ExpoCode
            unless (evts = evts_for(date, doc.ExpoCode)).empty?
                @entries << build_doc_evt(date, doc.Line, doc.ExpoCode,
                        filenamef(doc.FileName) + "\n" +
                        content_for_evts(evts))
            else
                if doc.FileName =~ /trk\.jpg$/
                    @entries << build_map(date, doc.Line, doc.ExpoCode,
                            doc.FileName)
                #elsif doc.FileName =~ /trk\.gif$/
                else
                    @entries << build_doc_no_evt(date, doc.Line,
                            doc.ExpoCode, doc.FileName)
                end #if
            end #unless
        end #docs.each
        unless (evts = no_doc_evts_for(date)).empty?
            evts.each do |evt|
                @entries << build_evt_no_doc(date, evt.Line, evt.ExpoCode,
                        content_for_no_doc_evt(evt))
            end #evts.each
        end #unless
    else
        unless (evts = no_doc_evts_for(date)).empty?
            evts.each do |evt|
                @entries << build_evt_no_doc(date, evt.Line, evt.ExpoCode,
                        content_for_no_doc_evt(evt))
            end #evts.each
        end #unless
        unless (submits = subs_for(date)).empty?
            submits.each do |sub|
                @entries << build_submission(date, sub.Line, sub.ExpoCode,
                        content_for_submit(sub))
            end #submits.each
        end #unless
    end #unless
end #downto


File.open("/tmp/dbh_#{Date.today.strftime($SHORT_DATE_F)}.batch", "w+") do |f|
    f.write(@entries.join("\n\n"))
    f.seek(0)
    outfile = "/Users/ayshen/dbhistory_err_#{Date.today.strftime($SHORT_DATE_F)}.ics"
    `python db_history_upload.py #{f.path} #{outfile}`
end
#puts @entries.join("\n\n")
