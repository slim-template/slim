module Slim
  # Given the following example:
  #   html
  #     head
  #       meta name="description" content="This is a Slim Test, that's all"
  #       title Simple Test Title
  #     body
  #       - if logged_in?
  #         p
  #           ` Welcome!
  #       - else
  #         p
  #           ` Please sign in.
  #
  # When compiling the above code to be eval'd, Slim produces a
  # compiled string that looks like:
  #
  #     buf = [];
  #     _buf << "<html>";
  #     _buf << "<head>";
  #     _buf << "<meta name=\"description\" content=\"This is a Slim Test, that's all\"/>";
  #     _buf << "<title>";
  #     _buf << "Simple Test Title";
  #     _buf << "</title>";
  #     _buf << "</head>";
  #     _buf << "<body>";
  #     if logged_in?;
  #     _buf << "<p>";
  #     _buf << "Welcome!";
  #     _buf << "</p>";
  #     else;
  #     _buf << "<p>";
  #     _buf << "Please sign in.";
  #     _buf << "</p>";
  #     end;
  #     _buf << "</body>";
  #     _buf << "</html>";
  #     _buf.join;
  #
  # The optimized string after:
  #
  #     buf = [];
  #     _buf << "<html><head><meta name=\"description\" content=\"This is a Slim Test, that's all\"/><title>Simple Test Title</title></head><body>";
  #     if logged_in?;
  #     _buf << "<p>Welcome!</p>";
  #     else;
  #     _buf << "<p>Please sign in.</p>";
  #     end;
  #     _buf << "</body></html>";
  #     _buf.join;
  module Optimizer
    def optimize
      @optimized = ""
      string     = nil

      @_buffer.each do |line|
        if line =~ /^_buf << "(.+)"/
          string ||= ""
          string << $1
        else
          @optimized << "_buf << \"#{string}\";" if string
          @optimized << line
          string = nil
        end
      end
      return nil
    end
  end # Optimizer
end # Slim
