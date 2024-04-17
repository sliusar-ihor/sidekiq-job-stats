# frozen_string_literal: true

require_relative "stats/version"

module Sidekiq
  module Job
    module Stats
      class Error < StandardError; end
    end
  end
end
