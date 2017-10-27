class InterchangeReader
  include TurboUtils

  def initialize graph_service_url
    #@not_external = prepare_manufacturers
    @graph_service_url = graph_service_url
  end

  def is_external_manufacturer? manufacturer_name
    @not_external.index manufacturer_name
  end

  def query_service id
    tries ||= 10
    begin
      url = "#{@graph_service_url}/parts/#{id}/interchanges"
      response = RestClient.get url
      JSON.parse response.body
    rescue Exception => e
      if (tries -= 1) > 0
        puts " Sku [#{id}], Attempt [#{tries.to_s}], Sleeping 1 sec ... "
        sleep 1
        retry
      else
        puts "Giving up, Sku [#{id}] "
        []
      end
    end
  end

  def get_attribute id
    response = query_service id
    response['parts']
  end
end