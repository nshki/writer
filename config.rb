#------------------------------------------------------------------------
# Configuration
#------------------------------------------------------------------------

activate :livereload
activate :directory_indexes

# Correct asset links on gh-pages
activate :relative_assets
set :relative_links, true

set :css_dir,    'stylesheets'
set :js_dir,     'javascripts'
set :images_dir, 'images'

configure :build do
  activate :minify_css
  activate :minify_javascript
end
