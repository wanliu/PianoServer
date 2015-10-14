module Overcommit::Hook::PostCheckout
  class MustReadInformation < Base
    SCRIPT_LOCATION = File.expand_path('../scripts/git_important.sh', __FILE__)

    def run
      result = execute(['sh', SCRIPT_LOCATION])
      return :pass if result.success?

      [:fail, result.stdout]
    end
  end
end
