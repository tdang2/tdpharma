module CategoryDataHelper
  def prepare_data
    s.categories << [c1, c2, c3, c4, c5, c6]
    s.reload
  end
end

RSpec.configure do |config|
  config.include CategoryDataHelper
end

RSpec.shared_context 'category params' do
  let(:c1) {create(:category)}
  let(:c2) {create(:category)}
  let(:c3) {create(:category, parent_id: c1.id)} # first level sub cat
  let(:c4) {create(:category, parent_id: c1.id)}
  let(:c5) {create(:category, parent_id: c2.id)}
  let(:c6) {create(:category, parent_id: c3.id)} # second level sub cat
  let(:category_params) do
    {
        name: 'whatever',
        parent_id: c3.id,
        image_attributes: {photo: nil}
    }
  end
end
