module Overcommit::Hook::PostCheckout
  class MustReadInformation < Base
    SCRIPT_LOCATION = File.expand_path('../scripts/git_important.sh', __FILE__)

    def run
      result = execute(['sh', SCRIPT_LOCATION])
      puts last_read_commit
      return :pass if result.success?

      [:fail, result.stdout]
    end

    def last_read_commit
      Dir.glob(File.expand_path('../must_read_information/.read/*.*', __FILE__)).max { |a,b| File.ctime(a) <=> File.ctime(b) }
    end
  end
end
