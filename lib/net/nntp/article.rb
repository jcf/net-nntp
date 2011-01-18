
module Net
  class NNTP
    class Article
      attr_accessor :body, :headers
    
      def initialize
        @headers = {}
        @body = ""
      end
      
      def self.parse(string)
        article_obj = self.new
        header_string, article_obj.body = string.split("\r\n\r\n", 2)
        
        header_lines = []
        line_buffer = ""
        header_string.split("\n").each do |line|
          if line.scan(/[^\\]"/).length % 2 == 0 # ]/
            header_lines << line_buffer + line
            line_buffer = ""
            next
          end
          
          line_buffer += line
        end
        
        header_lines.each do |line|
          name, value = line.split(":", 2)
          article_obj[name.strip.capitalize] = value.strip
        end
        
        article_obj.body ||= ""
        
        article_obj
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
