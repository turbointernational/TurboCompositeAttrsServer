class GasketTurboReader

  extend Forwardable
  def_delegator :@interchange_getter, :get_interchange_attribute, :get_interchange_attribute

  include TurboUtils
  def initialize
    @interchange_getter = InterchangeGetter.new
  end

  private
  def get_gasket_kit_id id
    part = Turbo.find id
    part.gasket_kit_id
  end

  def get_gasket_kit gasket_kit_id
    unless gasket_kit_id.nil?
      gasket_kit = Part.find gasket_kit_id
      interchanges = get_interchange_attribute(gasket_kit_id)
      g = {
          id: gasket_kit_id,
          ti_id: get_ti_part_id(gasket_kit, interchanges),
          part_number: get_oe_part_number(gasket_kit),
          ti_part_number: get_ti_part_number(gasket_kit, interchanges),
          description: gasket_kit.description,
          prices: nil,
          interchanges: interchanges

      }
      rid_of_ti_interchange(g, interchanges)
    end
  end

  public
  def get_attribute id
    get_gasket_kit(get_gasket_kit_id(id))
  end
end