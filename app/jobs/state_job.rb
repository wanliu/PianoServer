class StateJob < ActiveJob::Base
  before_enqueue do |job|
    pp "before_enqueue"
  end

  after_enqueue do |job|
    pp "after_enqueue"
  end

  before_perform do |job|
    pp "before_perform", job
  end

  after_perform do |job|
    pp "after_perform", job
  end
end
