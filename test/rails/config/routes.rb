Dummy::Application.routes.draw do
  resources :entries
  get "/slim/normal", to: "slim#normal"
  get "/slim/variant", to: "slim#variant"
  get "/slim/xml", to: "slim#xml"
  get "/slim/helper", to: "slim#helper"
  get "/slim/erb", to: "slim#erb"
  get "/slim/no_layout", to: "slim#no_layout"
  get "/slim/variables", to: "slim#variables"
  get "/slim/partial", to: "slim#partial"
  get "/slim/integers", to: "slim#integers"
  get "/slim/thread_options", to: "slim#thread_options"
  get "/slim/content_for", to: "slim#content_for"
  get "/slim/attributes", to: "slim#attributes"
  get "/slim/splat", to: "slim#splat"
  get "/slim/splat_with_delimiter", to: "slim#splat_with_delimiter"
end
