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
      [:slim, :attrvalue, Bool, String]

    HTMLAttr <<
      [:slim, :splat, String]
  end
end
