module Overcommit::Hook::PostCheckout
  class MustReadInfomation < Base
    SCRIPT_LOCATION = Overcommit::Utils.script_path('gerrit-change-id')

    def run
      result = execute(['sh', SCRIPT_LOCATION, commit_message_file])

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
