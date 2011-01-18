
module Net
  class NNTP
    class Message
      attr_accessor :body, :headers
    
      def initialize
        @headers = {}
        @body = ""
      end
      
      def self.parse(string)
        object = self.new
        header_string, object.body = string.split("\r\n\r\n", 2)
        
        header_string.split("\n").each do |header_line|
          name, value = header_line.strip.split(":", 2).map {|x| x.strip}
          object[name] = value
        end
        
        object
      end
      
      def []=(name, value)
        @headers[name] = value
      end
      
      def [](name)
        @headers[name]
      end
    end
  end
end
