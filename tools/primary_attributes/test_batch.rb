require_relative '../mappers_helper'
require_relative 'worker_classes'


class PrimaryAttributeReader
  include Celluloid
  def initialize graph_service_url
    @interchange_worker = InterchangeReader.new graph_service_url
    @bom_worker = BomReader.new graph_service_url
    @where_worker = WhereUsedAttrReader.new graph_service_url

  end

  def set_attribute sku
    @interchange_worker.get_attribute sku
    @bom_worker.get_attribute sku
    @where_worker.get_attribute sku
    "Future Finished sku [#{sku}]"
  end
end

class PrimaryAttributeWorker
  include Celluloid

  def initialize redis_cache, graph_service_url
    @interchange_worker = InterchangeSetter.new redis_cache,graph_service_url
    @bom_worker = BomSetter.new redis_cache,graph_service_url
    @where_worker = WhereUsedSetter.new redis_cache,graph_service_url
    #@service_kit_worker = ServiceKitSetter.new
    @sales_notes_worker = SalesNoteSetter.new redis_cache
  end

  def set_attribute sku
    @interchange_worker.set_interchange_attribute sku
    @bom_worker.set_bom_attribute sku
    @where_worker.set_where_used_attribute sku
    #@service_kit_worker.set_service_kit_attribute sku
    @sales_notes_worker.set_sales_note_attribute sku
    ActiveRecord::Base.clear_active_connections!
    "Future Finished sku [#{sku}]"
  end
end


pool_size = 4
completion_size = 0
redis_host = get_redis_host
redis_cache = RedisCache.new(Redis.new(:host => redis_host, :db => 3))
graph_service_url = get_service_configuration
#worker = PrimaryAttributeReader.pool size: pool_size, args: [graph_service_url]
worker = PrimaryAttributeWorker.pool size: pool_size, args: [redis_cache, graph_service_url]


def make_batch_future id, worker
  worker.future.set_attribute(id)
end


Part.find_in_batches(batch_size: pool_size).each do |group|
  futures = []

  ids = group.map do |part|
    futures.push make_batch_future(part.id, worker)
    part.id
  end

  puts "New Batch Ids => " + ids.join(",")

  initial_size = futures.size
  completion_size += initial_size
  #puts "Before: Initial size #{initial_size}, Futures Size: #{futures.size}"
  until are_futures_ready?(futures, initial_size)
    futures = remove_resolved_futures futures
  end
  #puts "After: Futures Resolved #{completion_size}"
end