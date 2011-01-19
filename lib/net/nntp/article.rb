require "base64"

module Net
  class NNTP
    class Article
      RFC2047_REGEXP = /(\=\?([^\x00-\x20]+)\?([^\x00-\x20]+)\?([^\? ]+)\?\=)/
    
      attr_accessor :body, :headers
    
      def initialize
        @headers = {}
        @body = ""
      end
      
      def self.decode_rfc2047(string)
        result = {}
        
        string.scan(RFC2047_REGEXP).to_a.each do |occur|
          origin, charset, encoding, source = occur
          encoding = encoding.downcase
          charset = charset.downcase
          subresult = nil
          
          if encoding == "q"
            subresult = source.gsub /\=([A-Za-z0-9]{2})/ do |match|
              match[1..-1].to_i(16).chr
            end
          elsif encoding == "g"
            subresult = Base64.decode64(source)
          end
          
          subresult = subresult.force_encoding(charset)
          subresult = subresult.encode("utf-8", charset)
          
          result[origin] = subresult
        end
        
        result_string = string
        result.each do |s,r|
          result_string = result_string.sub(s, r)
        end
        
        result_string
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
          begin
            article_obj[name.to_s.strip.capitalize] = decode_rfc2047(value.to_s.strip)
          rescue Exception => e
            puts e.inspect
          end
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
