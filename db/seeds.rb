# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Role.create(name: 'owner')
Role.create(name: 'manager')
Role.create(name: 'employee')

# First level category
c1 = Category.create(name: "Baby & Kids")
c2 = Category.create(name: "Beauty & Skincare")
c3 = Category.create(name: "Personal Care")
c4 = Category.create(name: "Diet & Fitness")
c5 = Category.create(name: "Medicine & Health")
c6 = Category.create(name: "Vitamin & Supplement")

# Second level category under Baby & Kids
Category.create(name: "Diapering & Potty", parent_id: c1.id)
Category.create(name: "Bath & Skincare", parent_id: c1.id)
Category.create(name: "Formula & Baby Food", parent_id: c1.id)
Category.create(name: "Feeding & Mealtime", parent_id: c1.id)
Category.create(name: "Baby Gear", parent_id: c1.id)
Category.create(name: "Children's Medicine & Health", parent_id: c1.id)

# Second level category under Beauty Skincare
Category.create(name: "Bath & Body", parent_id: c2.id)
Category.create(name: "Eye Cosmetics", parent_id: c2.id)
Category.create(name: "Foundation, Blush & Bronzer", parent_id: c2.id)
Category.create(name: "Lipsticks & Lip Balm", parent_id: c2.id)
Category.create(name: "Sun Care", parent_id: c2.id)
Category.create(name: "Skincare Oils & Supplements", parent_id: c2.id)
Category.create(name: "Facial Skincare", parent_id: c2.id)

# Second level category under Personal Care
Category.create(name: "Hair Care", parent_id: c3.id)
Category.create(name: "Oral Care", parent_id: c3.id)
Category.create(name: 'Eye Care', parent_id: c3.id)
Category.create(name: "Feminine Care", parent_id: c3.id)
Category.create(name: "Antiperspirant & Deodorant", parent_id: c3.id)
Category.create(name: "Bladder Protection & Incontinence", parent_id: c3.id)
Category.create(name: "Cotton Balls & Swabs", parent_id: c3.id)
Category.create(name: "Wipes & Hand Sanitizers", parent_id: c3.id)
Category.create(name: "Family Planning", parent_id: c3.id)

# Second level category under Diet & Fitness
Category.create(name: "Nutrition", parent_id: c4.id)
Category.create(name: "Weight Management", parent_id: c4.id)
Category.create(name: "Sports Supplements", parent_id: c4.id)
Category.create(name: "Supplements", parent_id: c4.id)


# Second level category under Medicine & Health
Category.create(name: "Digestion", parent_id: c5.id)
Category.create(name: "Pain & Fever", parent_id: c5.id)
Category.create(name: "Homeopathic Remedies", parent_id: c5.id)
Category.create(name: "First Aid", parent_id: c5.id)
Category.create(name: "Cough, Cold & Flu", parent_id: c5.id)
Category.create(name: "Allergy & Sinus", parent_id: c5.id)
Category.create(name: "Hemorrhoid & Piles Treatment", parent_id: c5.id)
Category.create(name: "Diabetes", parent_id: c5.id)
Category.create(name: "Sleeping", parent_id: c5.id)
Category.create(name: "Women's Health", parent_id: c5.id)

# Second level category under Vitamin & Supplements
Category.create(name: "Multivitamins", parent_id: c6.id)
Category.create(name: "Calcium & Minerals", parent_id: c6.id)
Category.create(name: "Fish Oils & Omegas", parent_id: c6.id)
Category.create(name: "Enzymes", parent_id: c6.id)
Category.create(name: "Bee Supplements", parent_id: c6.id)
Category.create(name: "Vitamin", parent_id: c6.id)
Category.create(name: "Greens & Antioxidants", parent_id: c6.id)
Category.create(name: "Mushrooms", parent_id: c6.id)


s = Store.create(name: 'Store')
s.categories << Category.all
User.create(first_name: 'Robin', last_name: 'Dang', email: 'test@test.com', password: 'password', store_id: s.id)
User.create(first_name: 'Tri', last_name: 'Dang', email: 'tri@gmail.com', password: 'password', store_id: s.id)







