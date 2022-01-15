module Nocion
  module Config
    class << self
      def read!
        path = File.join(ENV['HOME'], '.nocion.json')
        @cfg = File.exists?(path) ? JSON.parse(File.read(path)) : {}
      end

      def key
        @cfg['key']
      end
    end

    read!
  end
end
