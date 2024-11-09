# frozen_string_literal: true

module RailsDbAnalytics
  class ReportDataComponent < ViewComponent::Base
    def initialize(report:)
      @report = report
    end

    private

    def render_data_section(title, data)
      tag.div(class: "mb-6") do
        concat tag.h3(title, class: "text-lg font-medium text-gray-900 mb-3")
        concat render_data_content(data)
      end
    end

    def render_data_content(data)
      case data
      when Array
        render_array_data(data)
      when Hash
        render_hash_data(data)
      else
        tag.p(data.to_s, class: "text-gray-600")
      end
    end

    def render_array_data(array)
      tag.ul(class: "space-y-2") do
        array.each do |item|
          concat tag.li(render_data_content(item), class: "text-gray-600")
        end
      end
    end

    def render_hash_data(hash)
      tag.dl(class: "grid grid-cols-1 gap-x-4 gap-y-4 sm:grid-cols-2") do
        hash.each do |key, value|
          concat tag.dt(key.to_s.titleize, class: "text-sm font-medium text-gray-500")
          concat tag.dd(render_data_content(value), class: "text-sm text-gray-900")
        end
      end
    end

    def chart_data?
      @report.report_data.any? { |k, v| numeric_data?(v) }
    end

    def numeric_data?(data)
      case data
      when Numeric
        true
      when Hash
        data.values.any? { |v| v.is_a?(Numeric) }
      when Array
        data.any? { |v| v.is_a?(Numeric) }
      else
        false
      end
    end
  end
end
