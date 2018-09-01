require 'slim/include'

require_relative 'helper.rb'

begin
  class SlimTest < Minitest::Test
    it 'renders .slim files includes with js embed' do
      slim_app { slim :embed_include_js }
      assert ok?
      assert_equal "<!DOCTYPE html><html><head><title>Slim Examples</title><script>alert('Slim supports embedded javascript!')</script></head><body><footer>Slim</footer></body></html>", body
    end

  end
rescue LoadError
  warn "#{$!}: skipping slim tests"
end
