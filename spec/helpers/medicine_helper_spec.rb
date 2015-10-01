RSpec.shared_context 'medicine params', :med_a => :med_b do
  let(:med1) {create(:medicine)}
  let(:med2) {create(:medicine)}
  let(:med3) {create(:medicine)}
  let(:med_params) do
    {
        name: 'Claritin',
        concentration: 10,
        concentration_unit: 'mg',
        med_form: 'tablets',
        med_batches_attributes: [
            {
              mfg_date: (Date.today - 3.months),
              expire_date: (Date.today + 3.months),
              package: 'Bottle',
              mfg_location: 'USA',
              store_id: @s.id,            # Same store as logged in user
              amount_per_pkg: 100,
              amount_unit: 'tablet',      # Most minimum unit inside the package
              total_units: 400,           # Total number of units (package * amount_per_pkg)
              total_price: 300,                 # Total price for the whole transaction
              user_id: u1.id,
              category_id: @c3.id
            },
            {
              mfg_date: (Date.today - 2.months),
              expire_date: (Date.today + 3.months),
              package: 'Bottle',
              mfg_location: 'USA',
              store_id: @s.id,
              amount_per_pkg: 100,
              amount_unit: 'tablet',      # Most minimum unit inside the package
              total_units: 800,           # Total number of units (package * amount_per_pkg)
              total_price: 500,                 # Total price for the whole transaction
              user_id: u1.id,
              category_id: @c3.id
            }
        ],
        image_attributes: {
            photo: nil
        }
    }
  end
end