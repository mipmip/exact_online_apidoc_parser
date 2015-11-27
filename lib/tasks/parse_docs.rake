require 'nokogiri'
require 'pp'
require 'ostruct'

# download index api rest doc
# download each resource api rest
desc 'apidoc_cache download Exact Online Api docs'
task :apidoc_cache do

  basedir = "tmp/cache"

  sh "rm -Rf #{basedir}"
  sh "mkdir -p  #{basedir}"

  parser = ExactOnlineApidocParser::Parse.new(basedir)

  sh "curl #{parser.base_url}HlpRestAPIResources.aspx?SourceAction=10 > #{basedir}/index.html"

  page = File.open("#{basedir}/index.html") { |f| Nokogiri::HTML(f) }
  resource_links = page.css("table#referencetable").css("tr").css("td").css("a")
  resource_links.each do |link|

    filepath = parser.endpoint_to_filepath(link.text)

    unless filepath.include? 'Function_Details'
      sh "curl #{parser.base_url}#{link['href']} > '#{filepath}'"
    end
  end
end


