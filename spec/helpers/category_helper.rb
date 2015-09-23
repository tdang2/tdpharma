module CategoryHelper
  def prepare_data
    @s = create(:store)
    @c1 = create(:category)    # master categories
    @c2 = create(:category)
    @c3 = create(:category, parent_id: @c1.id)  # first level sub categories
    @c4 = create(:category, parent_id: @c1.id)
    @c5 = create(:category, parent_id: @c2.id)
    @c6 = create(:category, parent_id: @c3.id) # second level sub categories
    @s.categories << [@c1, @c2, @c3, @c4, @c5, @c6]
    @s.reload
  end
end

RSpec.configure do |config|
  config.include CategoryHelper
end

