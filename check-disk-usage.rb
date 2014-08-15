#!/usr/bin/env ruby

require "sensu-plugin/check/cli"

class CheckDiskUsage < Sensu::Plugin::Check::CLI
  option :warning_over,
    description: "Warning if path's disk usage is over specified amount in megabytes.",
    short:       "-w N",
    long:        "--warning-over N",
    proc:        proc {|a| a.to_i }

  option :critical_over,
    description: "Critical if path's disk usage is over specified amount in megabytes.",
    short:       "-c N",
    long:        "--critical-over N",
    proc:        proc {|a| a.to_i }

  option :path,
    description: "Path to be checked.",
    short:       "-p PATH",
    long:        "--path PATH",
    required:    true

  def run
    message = "#{config[:path]} consumes #{disk_usage} megabytes"

    [:critical, :warning].each do |severity|
      threshold = config[:"#{severity}_over"]

      next unless threshold

      if disk_usage > threshold
        message << " (expected equal or lower than #{threshold} megabytes)."
        send severity, message
      end
    end

    message << "."
    ok message
  end

  private

  def disk_usage
    return @disk_usage if @disk_usage
    du = `du -ms #{config[:path]}`
    unknown "No such file or directory: #{config[:path]}" if du.empty?
    @disk_usage = du.split.first.to_i
  end
end
