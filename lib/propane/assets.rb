class Propane
  module Assets
    class << self
      def get(name)
        path = File.join(File.dirname(File.expand_path(__FILE__)), "../../assets/#{name}")
        File.binread(path)
      end
    end
  end
end
