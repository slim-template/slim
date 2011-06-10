module Slim
  # Slim expression grammar
  # @api private
  module Grammar
    extend Temple::Grammar

    Expression <<
      [:slim, :control, String, Expression]       |
      [:slim, :condcomment, String, Expression]   |
      [:slim, :output, Bool, String, Expression]  |
      [:slim, :interpolate, String]               |
      [:slim, :embedded, String, Expression]

    HTMLAttr <<
      [:slim, :attr, String, Bool, String]

  end
end
