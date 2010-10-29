module Slim
  # Slim helper functions
  #
  # @api public
  module Helpers
    extend self

    # Iterate over `Enumerable` object
    # yielding each element to a Slim block
    # and putting the result into `<li>` elements.
    # For example:
    #
    #     = list_of([1,2]) do |i|
    #       = i
    #
    # Produces:
    #
    #     <li>1</li>
    #     <li>2</li>
    #
    # @param enum [Enumerable] The enumerable objects to iterate over
    # @yield [item] A block which contains Slim code that goes within list items
    # @yieldparam item An element of `enum`
    # @api public
    def list_of(enum, &block)
      list = enum.map do |i|
        "<li>#{yield(i)}</li>"
      end.join("\n")
      list.respond_to?(:html_safe) ? list.html_safe : list
    end
  end
end
