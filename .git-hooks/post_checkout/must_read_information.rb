module Overcommit::Hook::PostCheckout
  class MustReadInformation < Base
    SCRIPT_LOCATION = File.expand_path('../scripts/git_important.sh', __FILE__)

    def run
      range = last_read_commit.empty? ? '' : "#{last_read_commit}..HEAD"
      revs = `git log #{range} --pretty=oneline --grep "must_read\:"`


      lines = revs.lines.map do |line|
        rev = line.split(' ')[0]
        msg = `git show -s --format=%B #{rev}`
        msg =~ /must_read\:\s+(.*)\n?\n?/m
        # touch rev
        $1.strip!
      end

      if !lines.empty?
        lines.unshift <<-OUTPUT

###################################
###### Important Information ######
###################################

        OUTPUT

        [ :warn, lines.join("\n") ]
      else
        :pass
      end
    end

    def last_filename
      Dir.glob(File.expand_path('../must_read_information/.read/*', __FILE__)).max { |a,b| File.ctime(a) <=> File.ctime(b) }
    end

    def last_read_commit
      last_filename ? File.basename(last_filename) : ''
    end

    def touch(id)
      FileUtils.touch File.expand_path('../must_read_information/.read/' + id, __FILE__)
    end
  end
end
