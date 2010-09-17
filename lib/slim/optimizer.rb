module Slim
  module Optimizer
    def optimize
      @optimized = ""
      string = nil
      @_buffer.each do |line|
        if line =~ /^_buf << "(.+)"/
          string ||= ""
          string << $1
        else
          if string
            @optimized << "_buf << \"#{string}\";"
          end
          @optimized << line
          string = nil
        end
      end
    end
  end
end
