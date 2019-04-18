module SeedsHelper
  def display_seed_quantity(seed)
    if seed.quantity.nil?
      'seeds'
    else
      pluralize(seed.quantity, 'seed')
    end
  end

  def display_seed_description(seed)
    if seed.description.present?
      truncate(seed.description, length: 130, separator: ' ', omission: '... ') { link_to "Read more", seed_path(seed) }
    else
      ''
    end
  end
end
