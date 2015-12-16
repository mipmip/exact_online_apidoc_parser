class String
  def underscore
    self.gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      tr("-", "_").
      downcase
  end

  def wrap(width=78, indent=0)
    ind=''
    indent.times do
      ind= ind + " "
    end

    self.gsub(/(.{1,#{width}})(\s+|\Z)/, "#{ind}\\1\n")
  end
end


require "exact_online_apidoc_parser/version"

spec = Gem::Specification.find_by_name 'exact_online_apidoc_parser'
Dir.glob("#{spec.gem_dir}/lib/tasks/*.rake").each { |r| import r }

module ExactOnlineApidocParser
  class Parse

    def initialize(api_dir)
      @api_dir = api_dir
    end

    def base_url
      "https://start.exactonline.nl/docs/"
    end

    def endpoint_to_filename(filename)
      if filename
        filename.gsub(/[^\w\s_-]+/, '')
          .gsub(/(^|\b\s)\s+($|\s?\b)/, '\\1\\2')
          .gsub(/\s+/, '_')
      end
    end

    def endpoint_to_filepath(filename)
      "#{@api_dir}/#{self.endpoint_to_filename(filename)}.html"
    end

    def el_to_attr(raw_el)
      page = Nokogiri::HTML(raw_el)
      page.text.strip
    end

    def api_tree
      resources = {}

      page = File.open("#{@api_dir}/index.html") { |f| Nokogiri::HTML(f) }
      resource_sections = page.css("table#referencetable").css("tr")
      resource_sections.each do |res|

        r ={}
        filename=''
        res.css("td")[1].css('a').select.each do |l|
          r['api_url'] = l['href']
          filename = endpoint_to_filepath(l.text)
        end

        r['service'] = res.css("td")[0].text
        r['end_point'] = res.css("td")[1].css('a').text.gsub("/","")
        r['base_path'] =  res.css("td")[2].text.split('{division}/')[1] if res.css("td")[2].text
        r['mandatory_attributes'] = [] #depr.
        r['other_attributes'] = [] #depr.
        r['related_attributes'] = [] #depr.
        r['all_attributes'] = []
        r['supported_methods'] = res.css("td")[3].text

        if File.exists? filename

          respage = File.open(filename) { |f| Nokogiri::HTML(f) }
          rows = respage.css('table#referencetable tr')
          rows.each do |tr|
            begin
              #mandatory = false
              raw_el = tr.css('td')[1].inner_html.strip
              element_name = el_to_attr(raw_el)
              type = el_to_attr(tr.css('td')[4].inner_html.strip)
              desc = tr.css('td')[5].inner_html.strip


              if raw_el.include?('Mandatory')
                r['mandatory_attributes'] << element_name ## Depr.
                mandatory = true
              end

              if raw_el.include?('HlpRestAPIResourcesDetails')
                r['related_attributes'] << element_name ## Depr.
                foreign_end_point = raw_el.split('name=')[1].split('"')[0]
              end
              r['other_attributes'] << element_name ## Depr.

              r['all_attributes'] << {'name' => element_name,
                                      'type'=> type,
                                      'desc' => desc,
                                      'foreign_end_point' => foreign_end_point,
                                      'mandatory' => mandatory}


            rescue
            end
          end
        end
        resources[r['end_point']] = r unless r['end_point'] == ''

      end
      resources
    end
  end
end
