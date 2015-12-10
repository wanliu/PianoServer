require 'sidekiq/api'

module JobService
  extend self

  def start(_name, owner, *args)
    options = args.extract_options!

    job = Job.find_or_initialize_by jobable: owner, job_type: options[:type]
    job.status = "pending"
    job.start_at = Time.now
    job.save

    klass = "::#{_name.to_s.camelize}Job".safe_constantize


    sync = config_or_sync_options(options)
    perform_method = sync ? :perform_now : :perform_later

    klass.send(perform_method, job, *args)
    job
  end

  def sidekiq_is_running?
    worker_api = Sidekiq::Workers.new
    worker_api.each.map.size > 0
  end

  def config_or_sync_options(options)
    force_sync ? true : options_sync(options)
  end

  def options_sync(options)
    options[:sync].nil? ? !sidekiq_is_running? : options[:sync]
  end

  def force_sync
    Settings.job.respond_to?(:force_sync) && Settings.job.send(:force_sync)
  end
end
