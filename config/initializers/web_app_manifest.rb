# This makes files with .webmanifest extension first class files in the asset
# pipeline. This is to preserve this extension, as is it referenced in a call
# to asset_path in the _favicon.html.erb partial.

if Rails.application.config.respond_to?(:assets)
  Rails.application.config.assets.configure do |env|
    mime_type = "application/manifest+json"
    extensions = [ ".webmanifest" ]

    if Sprockets::VERSION.to_i >= 4
      extensions << ".webmanifest.erb"
      env.register_preprocessor(mime_type, Sprockets::ERBProcessor)
    end

    env.register_mime_type(mime_type, extensions: extensions)
  end
end
