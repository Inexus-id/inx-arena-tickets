#!/usr/bin/env ruby 
require 'nokogiri'
require 'csv'
class Ticket
  def initialize(name, number)
    @name = name
    @number = number
  end

  def build
    # Svg file should has text element with id '#tspan6398'
    # the name should should be tiket.svg
    f = File.open("ticket.svg")
    doc = Nokogiri::XML(f)
    f.close
    doc.at_css("#tspan6398").content = @name
    File.open("tickets/#{@number}.svg", 'a') { |f| f.write(doc.to_xml) }
    "tickets/#{@number}.svg"
  end
end

# CSV data should has name data.csv
# Use the first columns for add to the svg file 
# and save with column_content.svg into tickets directory  
uniq_names = []
CSV.foreach("data.csv") do |row|
  uniq_names << row[0]
end

svg_files = []
index = 0
uniq_names.uniq.map{|n| (n.length > 20 ? n[/(.*)\s/,1] : n)}.each do |row|
  t = Ticket.new(row, index)
  svg_files << t.build
  index += 1
end

# Create with imagemagick the image matrix

# Set border for images
border = " -bordercolor '#ffd374' -border 2x2 "

# Create pdf files with 42 tickets per page
svg_files.each_slice(30).with_index do | images, page |
  lines = []
  images.each_slice(6) do | row |
    lines << row.join(' ') + border
  end
  image_matrix = lines.map {| line | "'(' #{line} +append ')'"}.join(' ')
  `convert #{image_matrix} -append pdf/page-#{page + 1}.pdf`
end
