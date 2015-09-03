require 'rails_helper'

RSpec.describe Image, type: :model do
  it { should have_attached_file(:photo) }
  it { should validate_attachment_content_type(:photo).allowing('image/png', 'image/gif').rejecting('text/plain', 'text/xml') }

end
