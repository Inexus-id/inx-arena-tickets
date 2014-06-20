#!/usr/bin/env ruby 
require 'nokogiri'
require 'csv'
# Create tickets and pdf files directory
`mkdir tickets pdf`
# Delete previous pdf files
`rm pdf/*`

class Ticket
  def initialize(name)
    @name = name
  end

  def build
    # Svg file should has text element with id '#tspan6398'
    # the name should should be tiket.svg
    f = File.open("ticket.svg")
    doc = Nokogiri::XML(f)
    f.close
    doc.at_css("#tspan6398").content = @name
    File.open("entradas/#{@name}.svg", 'a') { |f| f.write(doc.to_xml) }
    "tickets/#{@name}.svg"
  end
end

# CSV data should has name data.csv
# Use the first columns for add to the svg file 
# and save with column_content.svg into tickets directory  
svg_files = []
CSV.foreach("data.csv") do |row|
  t = Ticket.new(row[0])
  svg_files << t.build
end

# Create with imagemagick the image matrix

# Set border for images
border = " -bordercolor '#fff' -border 3x3 "

# Create pdf files with 42 tickets per page
svg_files.each_slice(42).with_index do | images, page |
  lines = []
  images.each_slice(7) do | row |
    lines << row.join(' ') + border
  end
  image_matrix = lines.map {| line | "'(' #{line} +append ')'"}.join(' ')
  `convert #{image_matrix} -append pdf/page-#{page + 1}.pdf`
end

# Remove tickets files
`rm tickets/*`
