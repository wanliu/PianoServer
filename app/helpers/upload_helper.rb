module UploadHelper

  def form_for(*args, &block)
    options = args.extract_options!
    options[:builder] = UploadFormBuilder

    super(*args, options, &block)
  end
end
