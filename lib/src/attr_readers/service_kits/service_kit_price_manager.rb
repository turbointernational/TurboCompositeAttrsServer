class ServiceKitPriceManager
  def initialize
    @group_price = GroupPrices.new
  end
  def add_group_price sks, id
    group_id = @group_price.prices[id]
    unless sks.nil?
      sks.each_with_index do |value, index|
        unless value[:prices].nil?
          sks[index][:prices] = value[:prices][group_id.to_sym]
        end
      end
    end
  end

  def remove_sk_price sks
    unless sks.nil?
      sks.each_with_index do |value,index|
        sks[index][:prices] = 'login'
      end
    end
  end

end