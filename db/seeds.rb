# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Role.find_or_create_by(name: 'owner')
Role.find_or_create_by(name: 'manager')
Role.find_or_create_by(name: 'employee')

# First level category
c1 = Category.find_or_create_by(name: "Baby & Kids")
c2 = Category.find_or_create_by(name: "Beauty & Skincare")
c3 = Category.find_or_create_by(name: "Personal Care")
c4 = Category.find_or_create_by(name: "Diet & Fitness")
c5 = Category.find_or_create_by(name: "Medicine & Health")
c6 = Category.find_or_create_by(name: "Vitamin & Supplement")

# Second level category under Baby & Kids
Category.find_or_create_by(name: "Diapering & Potty", parent_id: c1.id)
Category.find_or_create_by(name: "Bath & Skincare", parent_id: c1.id)
Category.find_or_create_by(name: "Formula & Baby Food", parent_id: c1.id)
Category.find_or_create_by(name: "Feeding & Mealtime", parent_id: c1.id)
Category.find_or_create_by(name: "Baby Gear", parent_id: c1.id)
Category.find_or_create_by(name: "Children's Medicine & Health", parent_id: c1.id)

# Second level category under Beauty Skincare
Category.find_or_create_by(name: "Bath & Body", parent_id: c2.id)
Category.find_or_create_by(name: "Eye Cosmetics", parent_id: c2.id)
Category.find_or_create_by(name: "Foundation, Blush & Bronzer", parent_id: c2.id)
Category.find_or_create_by(name: "Lipsticks & Lip Balm", parent_id: c2.id)
Category.find_or_create_by(name: "Sun Care", parent_id: c2.id)
Category.find_or_create_by(name: "Skincare Oils & Supplements", parent_id: c2.id)
Category.find_or_create_by(name: "Facial Skincare", parent_id: c2.id)

# Second level category under Personal Care
Category.find_or_create_by(name: "Hair Care", parent_id: c3.id)
Category.find_or_create_by(name: "Oral Care", parent_id: c3.id)
Category.find_or_create_by(name: 'Eye Care', parent_id: c3.id)
Category.find_or_create_by(name: "Feminine Care", parent_id: c3.id)
Category.find_or_create_by(name: "Antiperspirant & Deodorant", parent_id: c3.id)
Category.find_or_create_by(name: "Bladder Protection & Incontinence", parent_id: c3.id)
Category.find_or_create_by(name: "Cotton Balls & Swabs", parent_id: c3.id)
Category.find_or_create_by(name: "Wipes & Hand Sanitizers", parent_id: c3.id)
Category.find_or_create_by(name: "Family Planning", parent_id: c3.id)

# Second level category under Diet & Fitness
Category.find_or_create_by(name: "Nutrition", parent_id: c4.id)
Category.find_or_create_by(name: "Weight Management", parent_id: c4.id)
Category.find_or_create_by(name: "Sports Supplements", parent_id: c4.id)
Category.find_or_create_by(name: "Supplements", parent_id: c4.id)


# Second level category under Medicine & Health
Category.find_or_create_by(name: "Digestion", parent_id: c5.id)
Category.find_or_create_by(name: "Pain & Fever", parent_id: c5.id)
Category.find_or_create_by(name: "First Aid", parent_id: c5.id)
Category.find_or_create_by(name: "Cough, Cold & Flu", parent_id: c5.id)
Category.find_or_create_by(name: "Allergy & Sinus", parent_id: c5.id)
Category.find_or_create_by(name: "Diabetes", parent_id: c5.id)
Category.find_or_create_by(name: "Sleeping", parent_id: c5.id)
Category.find_or_create_by(name: "Women's Health", parent_id: c5.id)

# Second level category under Vitamin & Supplements
Category.find_or_create_by(name: "Multivitamins", parent_id: c6.id)
Category.find_or_create_by(name: "Calcium & Minerals", parent_id: c6.id)
Category.find_or_create_by(name: "Fish Oils & Omegas", parent_id: c6.id)
Category.find_or_create_by(name: "Enzymes", parent_id: c6.id)
Category.find_or_create_by(name: "Bee Supplements", parent_id: c6.id)
Category.find_or_create_by(name: "Vitamin", parent_id: c6.id)
Category.find_or_create_by(name: "Greens & Antioxidants", parent_id: c6.id)
Category.find_or_create_by(name: "Mushrooms", parent_id: c6.id)

# Build up first store and employees
s = Store.find_or_create_by(name: 'Store')
s.categories << Category.all
u1 = User.create(first_name: 'Robin', last_name: 'Dang', email: 'test@test.com', password: 'password', store_id: s.id, preferred_language: 'vn')
u2 = User.create(first_name: 'Tri', last_name: 'Dang', email: 'tri@gmail.com', password: 'password', store_id: s.id, preferred_language: 'en')
u_list = [u1, u2]

# Build up medicine seeds
c_a_list = [100, 150, 200, 250, 400, 450]
c_u_list = %w(mg ml cc)
m_f_list   = %w(tablet tube pill capsule)
mfg_d_list = [3, 4, 5, 6]
exp_d_list = [6, 7, 8, 12]
pkg_list = %w(Bottle Bag Box)
mfg_l_list = %w(USA France Germany Korea Japan Vietnam)
manufacturer = %w(Pifzer Vertex GlascoSmithlite NatureLite)
Category.last_level.each do |c|
  # For each second category, build 100 medicine
  100.times do |t|
    form = m_f_list[rand(0..3)]
    mfg = manufacturer[rand(0..3)]
    m = Medicine.find_or_create_by(name: (c.name+t.to_s), concentration: c_a_list[rand(0..5)], mfg_location: mfg_l_list[rand(0..5)],
                                   concentration_unit: c_u_list[rand(0..2)], med_form: form, manufacturer: mfg)
    num_pkg = rand(1..10)
    amt_pkg = rand(20..120)
    m.update!(med_batches_attributes: [
                  {
                      mfg_date: (Date.today - mfg_d_list[rand(0..3)].months),
                      expire_date: (Date.today + exp_d_list[rand(0..3)].months),
                      package: pkg_list[rand(0..2)],
                      store_id: s.id,            # Same store as logged in user
                      amount_per_pkg: amt_pkg,
                      number_pkg: num_pkg,
                      total_units: amt_pkg*num_pkg, # Total number of units (number of package * amount_per_pkg)
                      total_price: rand(10..3000),# Total price for the whole transaction
                      user_id: u_list[rand(0..1)].id,
                      category_id: c.id
                  }
              ])
  end
end










