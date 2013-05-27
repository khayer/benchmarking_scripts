require "./geneinfo.rb"
require "./gff.rb"

class CompareGenes
  def initialize(gff_file,geneinfo_file)
    @gff = GFF.new(gff_file)
    @geneinfo = GeneInfo.new(geneinfo_file)
  end

  attr_accessor :gff, :geneinfo

  def statistics()
    @gff.create_index()
    @geneinfo.create_index()
    stats = 0
    @gff.index.each_key do |info|    
      @geneinfo.index.each_key do |key|
        if key[0] == info[0] && key[1] == info[1]
          geneinfo_transcript= @geneinfo.transcript(key[0],key[1],key[2])
          gff_transcript = @gff.transcript(info[0],info[1],info[2])
          stats += 1 if geneinfo_transcript == gff_transcript
        end
      end
    end
    stats
  end
end