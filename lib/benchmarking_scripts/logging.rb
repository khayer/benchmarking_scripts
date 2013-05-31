module Logging
  # This is the magical bit that gets mixed into your classes
  def logger
    @logger ||= Logging.logger_for(self.class.name)
  end

  @loggers = {}

  # Global, memoized, lazy initialized instance of a logger
  class << self
    def logger_for(classname)
      @loggers[classname] ||= configure_logger_for(classname)
    end

    def configure_logger_for(classname)
      logger = Logger.new(STDERR)
      logger.progname = classname
      logger
    end
  end
end