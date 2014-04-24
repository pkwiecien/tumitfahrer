class ApiController < ActionController::Base

  include ActionController::Helpers
  include ActionController::Redirecting
  include ActionController::Rendering
  include ActionController::Renderers::All
  include ActionController::ConditionalGet

  # needed for responding to different types .json .xml etc...
  include ActionController::MimeResponds
  include ActionController::RequestForgeryProtection

  # needed while using SSL
  include ActionController::ForceSSL
  include AbstractController::Callbacks
  # needed to build params
  include ActionController::Instrumentation
  # needed to wrap_parameters
  include ActionController::ParamsWrapper

  # needed to make ApiController aware of your routes
  include Rails.application.routes.url_helpers

  # tell the controller where to look for templates
  append_view_path "#{Rails.root}/app/views"
  # needed to wrap the parameters correctly eg # { "person": { "name": "Zack", "email": "sakchai@artellectual.com", "twitter": "@artellectual" }}
  wrap_parameters format: [:json]

  # add restrict access here like on: http://www.amberbit.com/blog/2014/2/19/building-and-documenting-api-in-rails/

end