#!/usr/bin/env ruby

def escape_note (note)
    # FIXME
    # THIS FUNCTION DOES NOT CORRECT NON-ASCII UNICODE CHARACTERS IN YOUR
    # NOTES! YOU MUST NOT USE NON-ASCII CHARACTERS IN YOUR NOTES; THEY
    # WILL BREAK atom.Content !!!
    x = if note then note.strip.gsub(/(\r|\n|\r\n)+/, "\n") else "" end

    x.gsub(/\xa0/, "") # XXX haxx0red to avoid this character
end


def notef (first, last, note)
    "Who: #{first} #{last}\nNote: #{note}"
end


def content_for_evts (evts)
    (evts.collect do |evt|
        notef(evt.First_Name, evt.LastName, escape_note(evt.Note))
    end).join("\n")
end


def content_for_no_doc_evt (evt)
    notef(evt.First_Name, evt.LastName, escape_note(evt.Note))
end


def content_for_submit (sub)
    [
    "Filename: #{sub.file}",
    "Who: #{sub.name or "Anonymous"}, #{sub.institute or "independent"}",
    "Note: #{if sub.notes then escape_note(sub.notes) else "" end}"
    ].join("\n")
end

