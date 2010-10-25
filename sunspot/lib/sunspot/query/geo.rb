begin
  require 'geohash'
rescue LoadError => e
  require 'pr_geohash'
end

module Sunspot
  module Query
    class Geo
      MAX_PRECISION = 12
      DEFAULT_PRECISION = 7
      DEFAULT_PRECISION_FACTOR = 16.0

      def initialize(field, lat, lng, options)
        @field, @options = field, options
        @lat, @lng = lat, lng
        @geohash = GeoHash.encode(lat.to_f, lng.to_f, MAX_PRECISION)
      end

      def to_params
        { :q => to_boolean_query }
      end

      def to_subquery
        "(#{to_boolean_query})"
      end

      private

      def to_boolean_query
        queries = []
        boosted_geohashes = {}
        geohashes = {}

        # generate decreasingly-precise geohashes, with adjacent neighbors
        MAX_PRECISION.downto(precision) do |i|
          geohashes[i] = @geohash[0, i]
          geohashes[i - 0.5] = GeoHash.neighbors(@geohash[0, i])
        end
        
        # turn our geohashes into boosted query clauses
        geohashes.each do |p, geohash|
          star = p == MAX_PRECISION ? '' : '*'
          pb = precision_boost(boost, precision_factor, p)
          queries << "#{@field.indexed_name}:#{geohash}#{star}^#{pb}"
        end

        queries.join(' OR ')
      end
      
      def precision_boost(boost, precision_factor, precision)
        f = boost * precision_factor ** (precision-MAX_PRECISION).to_f
        Util.format_float(f, 3)
      end
      
      def precision
        @options[:precision] || DEFAULT_PRECISION
      end

      def precision_factor
        @options[:precision_factor] || DEFAULT_PRECISION_FACTOR
      end

      def boost
        @options[:boost] || 1.0
      end
    end
  end
end

if __FILE__ == $0
  require 'spec'

  describe "geo queries" do
    
    
    
  end
  
  exit ::Spec::Runner::CommandLine.run
end