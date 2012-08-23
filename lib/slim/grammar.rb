module Slim
  # Slim expression grammar
  # @api private
  module Grammar
    extend Temple::Grammar

    Expression <<
      [:slim, :control, String, Expression]           |
      [:slim, :output, Bool, String, Expression]      |
      [:slim, :interpolate, String]                   |
      [:slim, :embedded, String, Expression]          |
      [:slim, :text, Expression]                      |
      [:slim, :tag, String, SlimAttrs, 'Expression?']

    SlimAttrs <<
      [:slim, :attrs, 'SlimAttr*']

    SlimAttr <<
      HTMLAttr                             |
      [:slim, :attr, String, Bool, String] |
      [:slim, :splat, String]
  end
end
