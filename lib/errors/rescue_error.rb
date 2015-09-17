module Errors
  module RescueError

    def self.included(base)
      base.rescue_from Errors::ResponseError do |e|
        render file: "public/#{e.code}.html", :status => e.code, layout: false
      end
    end

  end
end
