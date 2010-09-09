#!/usr/bin/env ruby


def find_by_date (selection, table, order_by)
    [
    "SELECT #{selection} FROM #{table}",
    "JOIN cchdo.cruises ON #{table}.ExpoCode = cchdo.cruises.ExpoCode",
    "WHERE DATE_SUB(CURDATE(), interval 2 month) <= #{order_by}",
    "ORDER BY #{order_by} DESC"
    ].join(" ")
end


def selectionize (items, table)
   (items.map {|x| "#{table}.#{x}"} + ["cchdo.cruises.Line"]).join(", ")
end

