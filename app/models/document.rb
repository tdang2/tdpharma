class Document < ActiveRecord::Base
  ### Attributes ###################################################################################
  has_attached_file :doc

  ### Constants ####################################################################################
  DIRECT_UPLOAD_URL_FORMAT = ENV['DIRECT_UPLOAD_URL_FORMAT']

  ### Includes and Extensions ######################################################################

  ### Associations #################################################################################
  belongs_to :documentable, polymorphic: true

  ### Callbacks ####################################################################################
  before_save :set_upload_attributes
  after_save :queue_processing

  ### Validations ##################################################################################
  validates_attachment_content_type :doc, :content_type => ['application/pdf', 'image/jpg', 'image/jpeg', 'image/png', 'text/plain',
                                                            'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
                                                            'application/vnd.ms-excel', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet']

  ### Scopes #######################################################################################

  ### Other ########################################################################################

  ### Class Methods ################################################################################
  def self.transfer_and_cleanup(id)
    i = Document.find(id)
    if i.direct_upload_url
      i.doc = URI.parse(URI.escape(i.direct_upload_url))  # Download and re-processed the photo
      # S3_BUCKET.object(i.photo_file_name).copy_from({copy_source: i.direct_upload_url})   # Use this to just copy the photo over
      if i.save!
        i.update!(processed: true, direct_upload_url: nil)
      end
    end
  end

  ### Instance Methods #############################################################################
  def set_upload_attributes
    if (self.direct_upload_url)
      tries ||= 2
      doc_name = self.direct_upload_url.gsub(DIRECT_UPLOAD_URL_FORMAT, '')
      s3_doc = S3_PUBLIC_BUCKET.object(doc_name)
      self.processed = false
      self.photo_file_name = doc_name
      # TODO: Perform a check for content type before save so user can't just upload anything
      self.photo_file_size = s3_doc.content_length
      self.photo_content_type = s3_doc.content_type
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

  def queue_processing
    Document.delay.transfer_and_cleanup(id) if direct_upload_url and processed == false
  end

  private


end
