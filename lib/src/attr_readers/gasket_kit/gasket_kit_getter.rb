class GasketKitGetter
  extend Forwardable
  def_delegator :@price_manager, :remove_price, :remove_price
  def_delegator :@price_manager, :add_group_price, :add_group_price
  def_delegator :@decriptor, :get_customer_group, :get_customer_group

  def initialize redis_cache=RedisCache.new(Redis.new(:host => "redis", :db => 3))
    @redis_cache = redis_cache
    @price_manager = GasketKitPriceManager.new
    @decriptor = CustomerInfoDecypher.new
  end

  def get_cached_gasket_kit sku
    @redis_cache.get_cached_response sku, 'gasket_kit'
  end

  def get_gasket_kit_with_prices sku, id
    group_id = get_customer_group(id)
    turbos = get_cached_gasket_kit(sku)
    if group_id=='no stats'
      remove_price(turbos)
    else
      add_group_price(turbos, group_id)
    end
  end

  def get_gasket_kit_attribute sku, id
    get_gasket_kit_with_prices sku, id
  end
end