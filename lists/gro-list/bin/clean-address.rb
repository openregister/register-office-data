require 'morph'

def clean_address text
  begin
    lines = text.split(',').map(&:strip)
    last = lines.pop
    postcode = last[/[A-Z][A-Z0-9].+$/]
    lines << last.sub(postcode,'').strip
    {lines: lines, postcode: postcode}
  rescue TypeError => e
    puts text
    raise e
  end
end

list = Morph.from_tsv IO.read('gro-list-original.tsv'), :officer

list.delete_if {|x| (x.address1.blank? || x.address1.squeeze('"').size < 4)}

list.each {|o| o.address = [o.address1,o.address2,o.address3,o.address4].join(' ').squeeze(' ').strip } ; nil

puts %w[registration-district registration-district-name address1 address2 address3 address4 postcode].join("\t")

rows = {}
list.each do |x|
  cleaned = clean_address(x.address)
  lines = cleaned[:lines]
  postcode = cleaned[:postcode]
  row = [
    x.registration_district,
    x.registration_district_name,
    lines[0],
    lines[1],
    lines[2],
    lines[3],
    postcode
  ].join("\t")
  unless rows[row]
    puts row
    rows[row] = true
  end
end
