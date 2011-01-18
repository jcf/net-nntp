
module Net
  class NNTP
    class Response
      attr_accessor :code, :message
      
      def initialize
        @code = 000
        @message = ""
      end
      
      def self.parse(msg)
        msg = msg.strip
        obj = self.new
        obj.code, obj.message = msg.split(" ", 2)
        obj.code = obj.code.to_i
        
        obj
      end
    end
  end
end
