###
# Sprockets
###
require 'rake/file_list'
require 'pathname'
require 'date'

bower_directory = 'source/bower_components'

# Build search patterns
patterns = [
  '.png',  '.gif', '.jpg', '.jpeg', '.svg', # Images
  '.eot',  '.otf', '.svc', '.woff', '.ttf', # Fonts
  '.js',                                    # Javascript
].map { |e| File.join(bower_directory, "**", "*#{e}" ) }

# Create file list and exclude unwanted files
Rake::FileList.new(*patterns) do |l|
  l.exclude(/src/)
  l.exclude(/test/)
  l.exclude(/demo/)
  l.exclude { |f| !File.file? f }
end.each do |f|
  # Import relative paths
  sprockets.import_asset(Pathname.new(f).relative_path_from(Pathname.new(bower_directory)))
end

###
# Compass
###

compass_config do |config|
  # Require any additional compass plugins here.
  config.add_import_path "bower_components"
  config.add_import_path "bower_components/foundation/scss"
  config.add_import_path "bower_components/foundation-3/stylesheets"
  config.add_import_path "bower_components/normalize/"
  config.add_import_path "bower_components/bxslider-4/"
  config.add_import_path "bower_components/drexel/"

  # Set this to the root of your project when deployed:
  config.http_path = "#{data.ftp.path}/"
  config.css_dir = "stylesheets"
  config.sass_dir = "stylesheets"
  config.images_dir = "images"
  config.javascripts_dir = "javascripts"
  # config.layout_dir = "layouts"

  # You can select your preferred output style here (can be overridden via the command line):
  # output_style = :expanded or :nested or :compact or :compressed

  # To enable relative paths to assets via compass helper functions. Uncomment:
  # relative_assets = true

end

# Disable HAML warnings
Haml::TempleEngine.disable_option_validator!

###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
# page "/path/to/file.html", :layout => false
#
# With alternative layout
page "index.html", :layout => "home-page"

# data.pages.each do |page|
#   proxy "/#{page.url}.html", "/.html", :locals => { :title => page.title }, ignore => true
# end

#
# A path which all have the same layout
# with_layout :admin do
#   page "/admin/*"
# end

# Proxy pages (http://middlemanapp.com/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", :locals => {
#  :which_fake_page => "Rendering a fake page with a local variable" }

# Reload the browser automatically whenever files change
activate :livereload
activate :directory_indexes

set :http_prefix, "/"
set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'

set :haml, { :ugly => true, :format => :html5 }

helpers do
  def current_page?(page)
    if page.title == current_page.data.title
      return true
    else
      return false
    end
  end

  def current_page_is_a_sub_page?(page)
    is_sub_page = false                     # set the switch in the off position

    if page.sub_pages?
      page.sub_pages.each do |sub|
        if sub.title == current_page.data.title # if we are on the sub page
          is_sub_page = true                  # trip the switch
        end
      end
    end
    return is_sub_page                      # return the switch's state (true or false)
  end

  def test_values_compared_in_cp_vs_subpage(page)
    a = ""
    page.sub_pages.each do |sub|
      a+="<p>#{sub.title}, #{current_page.data.title} "
      a+="is #{sub.title == current_page.data.title}</p>"
    end
    return a
  end
end

# Add bower's directory to sprockets asset path
after_configuration do
  @bower_config = JSON.parse(IO.read("#{root}/.bowerrc"))
  sprockets.append_path File.join "#{root}", @bower_config["directory"]
end

# set :relative_links, true

activate :deploy do |deploy|
  # ...
  # deploy.build_before = true # default: false

  deploy.method   = :sftp
  deploy.host     = data.ftp.host
  deploy.path     = data.ftp.root + data.ftp.path
  deploy.user     = data.ftp.user
  deploy.password = data.ftp.pass
  deploy.path     = 22
end

# Build-specific configuration
configure :build do
  # Ignore irrelevant directories during build
  ignore 'bower_components/**'
  ignore '*.psd'

  # For example, change the Compass output style for deployment
  # activate :minify_css

  # Minify Javascript on build
  # activate :minify_javascript

  # Enable cache buster
  # activate :asset_hash

  # Use relative URLs
  # activate :relative_assets

  # set :relative_links, true

  # Or use a different image path
  set :http_prefix, "#{data.ftp.path}/"
end
