#!/usr/bin/env ruby

require 'date'

$DATEF = "%Y-%m-%d"


def title_for (line, expocode)
    "(#{line}) #{expocode}"
end


def filenamef (filename)
    "Filename: #{filename}"
end


def build_doc_evt (date, line, expocode, content)
    [
    date.strftime($DATEF),
    "DOC_EVT",
    title_for(line, expocode),
    content
    ].join("\n")
end


def build_doc_no_evt (date, line, expocode, filename)
    [
    date.strftime($DATEF),
    "DOC_NO_EVT",
    title_for(line, expocode),
    filenamef(filename)
    ].join("\n")
end


def build_evt_no_doc (date, line, expocode, content)
    [
    date.strftime($DATEF),
    "EVT_NO_DOC",
    title_for(line, expocode),
    content
    ].join("\n")
end


def build_map (date, line, expocode, filename)
    [
    date.strftime($DATEF),
    "MAP",
    title_for(line, expocode),
    filenamef(filename)
    ].join("\n")
end


def build_submission (date, line, expocode, content)
    [
    date.strftime($DATEF),
    "SUBMIT",
    title_for(line, expocode),
    content
    ].join("\n")
end

