module RandomGenerable
  extend ActiveSupport::Concern

  module ClassMethods
    def barcode_generate
      o = [('0'..'9'), ('A'..'Z')].map { |i| i.to_a }.flatten
      (0...10).map { o[rand(o.length)] }.join
    end
  end
end
