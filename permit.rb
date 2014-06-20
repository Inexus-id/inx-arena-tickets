#!/usr/bin/env ruby 
# Create with imagemagick the image matrix

# Set border for images
border = " -bordercolor '#fff' -border 3x3 "
svg_files = Array.new(42, 'permit.svg')
# Create pdf files with 42 tickets per page
svg_files.each_slice(42).with_index do | images, page |
  lines = []
  images.each_slice(7) do | row |
    lines << row.join(' ') + border
  end
  image_matrix = lines.map {| line | "'(' #{line} +append ')'"}.join(' ')
  `convert #{image_matrix} -append pdf/page-#{page + 1}.pdf`
end
