#========================================================================
# Guardfile
#========================================================================

#------------------------------------------------------------------------
# Watch, concatenate, and minify coffee
#------------------------------------------------------------------------
guard "concat", type:      "coffee", files:  %w(canvas cursor main),
                input_dir: "coffee", output: "coffee/concat/application"
guard "coffeescript", input: "coffee/concat", output: "js"
guard "uglify", destination_file: "js/application.js" do
  watch (%r{js/application.js})
end

#------------------------------------------------------------------------
# Compass
#------------------------------------------------------------------------
guard "compass" do
  watch(%r{^scss/(.*)\.s[ac]ss})
end

#------------------------------------------------------------------------
# Livereload
#------------------------------------------------------------------------
guard "livereload" do
  watch(%r{.+\.(css|html|js)$})
end
