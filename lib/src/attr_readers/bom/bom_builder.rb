class BomBuilder

  def has_ti_part bom
    (not bom[:ti_part_sku].nil?) and
        bom[:ti_part_sku].size > 0  and
        not bom[:ti_part_sku].first.nil?
  end

  def create_hash_key ti_part_sku, part, bom
    ti_part = load_ti_part ti_part_sku
    @ti_hash[ti_part_sku] = {
        :sku => ti_part_sku,
        :description => ti_part.description,
        :quantity => bom[:quantity],
        :part_type => ti_part.part_type.name,
        :part_number => ti_part.manfr_part_num,
        :name => ti_part.name || ti_part.part_type.name  + '-' + ti_part.manfr_part_num,
        :interchanges => [{:part_number => part.manfr_part_num, :sku => part.id}]
    }
  end

  def add_interchange ti_part_sku, part
    @ti_hash[ti_part_sku][:interchanges].
        push({:part_number => part.manfr_part_num, :sku => part.id})
  end

  def has_ti_sku_key ti_part_sku
    @ti_hash.has_key? ti_part_sku
  end

  def load_ti_part ti_part_sku
     Part.find ti_part_sku
  end

  def build_bom_object bom, part
    ti_part_sku = bom[:ti_part_sku].first
    if has_ti_sku_key ti_part_sku
      add_interchange ti_part_sku, part
    else
      create_hash_key ti_part_sku, part, bom
    end
  end

  def add_standard_attributes boms
    @ti_hash = {}
    boms.each_with_index do |bom|
      part = Part.find bom[:sku]
      if has_ti_part(bom)
        build_bom_object(bom , part)
      end
    end
    @ti_hash
  end

end