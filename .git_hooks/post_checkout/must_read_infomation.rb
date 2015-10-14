module Overcommit::Hook::PostCheckout
  class MustReadInfomation < Base
    def run
      # errors = []

      # applicable_files.each do |file|
      #   if File.read(file) !~ /^require 'spec_helper'/
      #     errors << "#{file}: missing `require 'spec_helper'`"
      #   end
      # end

      # return :fail, errors.join("\n") if errors.any?

      # :pass
    end
  end
end
