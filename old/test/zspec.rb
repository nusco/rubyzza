module Z
  class << self
    attr_accessor :all_zspecs, :covered_zspecs

    def spec(spec)
      (covered_zspecs << spec).uniq!
  
      unknown = covered_zspecs - all_zspecs
      raise "Unknown zspecs: #{unknown.inspect}" unless unknown.empty?
    end
    
    def report
      uncovered = all_zspecs - covered_zspecs
      puts "#{uncovered.size} uncovered zspecs: #{uncovered.inspect}"
    end
  end
end

Z.all_zspecs = %w{
  2 2.1 2.2 2.2.1 2.3 2.3.1 2.3.2 2.4 2.4.1 2.4.2 2.4.3 2.Remarks
}

Z.covered_zspecs = []
