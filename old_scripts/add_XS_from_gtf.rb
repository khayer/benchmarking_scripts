xs_tag = {}
ambiguous = {}

File.open(ARGV[1]).each do |line|
  line.chomp!
  fields = line.split("\t")
  add = true
  xs_tag.each_pair do |chr,bins|
    next unless chr == fields[0]
    bins.each_pair do |el, strand|
      if (fields[3].to_i <= el[0] && fields[4].to_i  < el[1]) && fields[4].to_i > el[0]
        if fields[6] == strand
          fields[4] = el[1]
          xs_tag[fields[0]].delete(bins)
        else
          add = false
          ambiguous[fields[0]] = {} unless ambiguous[fields[0]]
          ambiguous[fields[0]][[fields[3].to_i,el[1]]] = strand
        end
        break
      elsif (fields[3].to_i > el[0] && fields[4].to_i >= el[1])  && fields[3].to_i < el[1]
        if fields[6] == strand
          fields[3] = el[0]
          xs_tag[fields[0]].delete(bins)
        else
          add = false
          ambiguous[fields[0]] = {} unless ambiguous[fields[0]]
          ambiguous[fields[0]][[el[0],fields[4].to_i]] = strand
        end
        break
      elsif fields[3].to_i <= el[0] && fields[4].to_i >= el[1]
        if fields[6] == strand
          xs_tag[fields[0]].delete(bins)
        else
          add = false
          ambiguous[fields[0]] = {} unless ambiguous[fields[0]]
          ambiguous[fields[0]][[fields[3].to_i,fields[4].to_i]] = strand
        end
        break
      elsif fields[3].to_i > el[0] && fields[4].to_i < el[1]
        if fields[6] == strand
          # ALREADY INCLUDED
          add = false
          #fields[3] = el[0]
          #fields[4] = el[1]
        else
          add = false
          ambiguous[fields[0]] = {} unless ambiguous[fields[0]]
          ambiguous[fields[0]][[el[0],el[1]]] = strand
        end
        break
      end
    end
  end
  xs_tag[fields[0]] = {} unless xs_tag[fields[0]]
  xs_tag[fields[0]][fields[3].to_i/1000000.floor % 100] = {} unless xs_tag[fields[0]][fields[3].to_i/1000000.floor % 100]
  xs_tag[fields[0]][fields[3].to_i/1000000.floor % 100][[fields[3].to_i,fields[4].to_i]] = fields[6] if add
end

#puts xs_tag["chr1"].keys.sort.join("\t")
#puts ""
#puts ambiguous["chr1"].keys.sort.join("\t")
#puts xs_tag

#puts xs_tag["chr1"].keys.sort == ambiguous["chr1"].keys.sort
#exit

File.open(ARGV[0]).each do |line|
  line.chomp!
  if line =~ /^@/
    puts line
  else
    # NH:i:2CC:Z:=CP:i:19630587HI:i:0
    line = line.gsub("IH:i:1","NH:i:1")
    line.gsub(/HI:i:([0-9]+)/){"HI:i:#{$1.to_i-1}"}

    fields = line.split("\t")
    unless line =~ /XS/
      xs = nil
      e = xs_tag[fields[2]]
      #xs_tag.each_pair do |k,e|
      #next unless k == fields[2]
      k = e[fields[3].to_i/1000000.floor % 100]
      k.each_pair do |el,str|
        next if fields[3].to_i < el[0]
        next if fields[3].to_i > el[1]
        # CHECK IF IN AMBIGUOUS
        am = false
        if ambiguous[fields[2]]
          ambiguous[fields[2]].each_pair do |bin,st|
            #puts fields[2]
            #puts fields[3]
            #puts bin
            next if fields[3].to_i < bin[0]
            next if fields[3].to_i > bin[1]
            am = true
            break
          end
        end
        xs = "XS:A:#{str}" unless am
        break
      end
      fields << xs if xs

    end
    #fields[5] = "100M" if fields[5] =~ /M0N/
    #fields[4] = 50
    #fields[10] = "IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII"
    puts fields.join("\t")
  end
end