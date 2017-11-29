# encoding: utf-8

class AvatarUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  version :large do
    process resize_to_limit: [300, 300]
  end

  version :middle, from_version: :large do
    process resize_to_limit: [120, 120]
  end  

  version :small do
    process resize_to_limit: [80, 80]
  end

  def default_url(*args)
    ActionController::Base.helpers.asset_path("site/" + [version_name, "avatar.png"].compact.join('_'))
  end  

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def filename 
    if original_filename 
      @name ||= Digest::MD5.hexdigest(File.dirname(current_path))
      "#{@name}.#{file.extension}"
    end
  end
end
