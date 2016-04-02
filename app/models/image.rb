class Image < ActiveRecord::Base
  ### Attributes ###################################################################################
  has_attached_file :photo, :styles => { :medium => '300x300', :thumb => '100x100'},
                    :default_url => :set_default_url_on_type

  ### Constants ####################################################################################
  DIRECT_UPLOAD_URL_FORMAT = ENV['DIRECT_UPLOAD_URL_FORMAT']

  ### Includes and Extensions ######################################################################

  ### Associations #################################################################################
  belongs_to :imageable, polymorphic: true

  ### Callbacks ####################################################################################
  before_save :set_upload_attributes
  after_save :queue_processing

  ### Validations ##################################################################################
  validates_attachment_content_type :photo, content_type: /\Aimage\/.*\Z/

  ### Scopes #######################################################################################

  ### Other ########################################################################################

  ### Class Methods ################################################################################
  def self.transfer_and_cleanup(id)
    i = Image.find(id)
    if i.direct_upload_url
      s3_obj = S3_PUBLIC_CLIENT.get_object(bucket: ENV['S3_PUBLIC_BUCKET'], key: i.photo_file_name)  # Download and re-processed the photo
      base64_str = 'data:' + s3_obj.content_type + ';base64,' + Base64.encode64(s3_obj.body.read)
      if i.update!(photo: base64_str)
        i.update!(processed: true, direct_upload_url: nil)
      end
    end
  end

  ### Instance Methods #############################################################################
  def set_upload_attributes
    if self.direct_upload_url
      tries ||= 2
      photo_name = self.direct_upload_url.gsub(DIRECT_UPLOAD_URL_FORMAT, '')
      s3_photo = S3_PUBLIC_BUCKET.object(photo_name)
      self.processed = false
      self.photo_file_name = photo_name
      self.photo_file_size = s3_photo.content_length
      self.photo_content_type = s3_photo.content_type
    end
  rescue Aws::S3::Errors::NoSuchKey => e
    tries -= 1
    if tries > 0
      sleep(3)
      retry
    else
      false
    end
  end

  def photo_thumb
    photo.url(:thumb) if photo
  end

  def photo_medium
    photo.url(:medium) if photo
  end

  def queue_processing
    Image.delay.transfer_and_cleanup(id) if direct_upload_url and processed == false
  end

  private

  def set_default_url_on_type
    "/images/#{imageable_type.downcase}.svg"
  end


end
