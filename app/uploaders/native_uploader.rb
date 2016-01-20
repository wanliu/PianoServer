# encoding: utf-8

class NativeUploader < ImageUploader

  def store_dir
    "uploads/_all/#{mounted_as}"
  end

end
