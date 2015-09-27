RSpec.shared_context 'user params', :a => :b do
  let(:s)  { create(:store)}
  let(:u1) { create(:employee, store_id: s.id)}
  let(:u2) { create(:employee, store_id: s.id)}
  let(:u3) { create(:manager, store_id: s.id)}
  let(:role1) { Role.find_by_name('guest').nil? ? create(:role) : Role.find_by_name('guest')}

  let(:user_sign_in_params) do
    {
        email: u1.email,
        password: u1.password,
    }
  end
  let(:user_full_params) do
    {
        email: 'tri1@babson.edu',
        password: 'password',
        first_name: 'tri',
        last_name: 'dang'
    }
  end
  let(:users_patch_params) do
    {
        email: SecureRandom.base64 + '@babson.edu',
        first_name: 'trung',
        last_name: 'dang2',
        password: 'password2'
    }
  end
end