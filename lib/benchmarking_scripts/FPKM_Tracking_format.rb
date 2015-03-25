class FPKMTrackingFormat < FileFormats

  def initialize(filename)
    super(filename)
    @coverage_quantifiers = Hash.new()
  end

  attr_accessor :coverage

  def create_index()
    @index = {}
  end

  def transcript(key)
    transcript = []
  end

  def calculate_coverage()
    @filehandle.rewind
    @filehandle.each do |line|
      line.chomp!
      fields = line.split(" ")
      fpkm = fields[9].to_f
      @coverage_quantifiers[fields[0]] = fpkm
    end
  end

end