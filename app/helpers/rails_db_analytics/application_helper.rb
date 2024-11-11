# frozen_string_literal: true

module RailsDbAnalytics
  module ApplicationHelper
    def rails_db_analytics_importmap_tags(entry_point = "application", shim: true)
      safe_join [
        javascript_inline_importmap_tag(RailsDbAnalytics.configuration.importmap.to_json(resolver: self)),
        javascript_importmap_module_preload_tags(RailsDbAnalytics.configuration.importmap),
        (javascript_importmap_shim_nonce_configuration_tag if shim),
        (javascript_importmap_shim_tag if shim),
        javascript_import_module_tag(entry_point)
      ].compact, "\n"
    end

    def format_timestamp(timestamp)
      return unless timestamp

      time_ago_in_words(timestamp) + " ago"
    end

    def format_report_data(data)
      return "No data available" unless data.present?

      content_tag(:div, class: "space-y-4") do
        data.map do |key, value|
          concat(
            content_tag(:div) do
              concat content_tag(:h4, key.to_s.titleize, class: "text-sm font-medium text-gray-700 mb-1")
              concat format_value(value)
            end
          )
        end
      end
    end

    private

    def format_value(value)
      case value
      when Array
        format_array(value)
      when Hash
        format_hash(value)
      else
        content_tag(:div, value.to_s, class: "text-gray-600 ml-4")
      end
    end

    def format_array(array)
      content_tag(:ul, class: "list-disc list-inside text-gray-600 ml-4") do
        array.map { |item| concat content_tag(:li, item) }
      end
    end

    def format_hash(hash)
      content_tag(:div, class: "ml-4") do
        hash.map do |k, v|
          concat(
            content_tag(:div, class: "text-gray-600") do
              concat content_tag(:span, k.to_s.titleize + ":", class: "font-medium")
              concat " #{v}"
            end
          )
        end
      end
    end

    def button_classes(variant = :primary)
      base_classes = "inline-flex items-center px-4 py-2 border text-sm font-medium rounded-md focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"

      case variant
      when :primary
        "#{base_classes} border-transparent text-white bg-blue-600 hover:bg-blue-700"
      when :secondary
        "#{base_classes} border-gray-300 text-gray-700 bg-white hover:bg-gray-50"
      when :danger
        "#{base_classes} border-transparent text-white bg-red-600 hover:bg-red-700"
      end
    end

    def icon(name, options = {})
      size = options.delete(:size) || 5
      classes = "h-#{size} w-#{size} #{options[:class]}"

      case name
      when :refresh
        <<~SVG.html_safe
          <svg xmlns="http://www.w3.org/2000/svg" class="#{classes}" viewBox="0 0 20 20" fill="currentColor">
            <path fill-rule="evenodd" d="M4 2a1 1 0 011 1v2.101a7.002 7.002 0 0111.601 2.566 1 1 0 11-1.885.666A5.002 5.002 0 005.999 7H9a1 1 0 010 2H4a1 1 0 01-1-1V3a1 1 0 011-1zm.008 9.057a1 1 0 011.276.61A5.002 5.002 0 0014.001 13H11a1 1 0 110-2h5a1 1 0 011 1v5a1 1 0 11-2 0v-2.101a7.002 7.002 0 01-11.601-2.566 1 1 0 01.61-1.276z" clip-rule="evenodd" />
          </svg>
        SVG
      when :close
        <<~SVG.html_safe
          <svg xmlns="http://www.w3.org/2000/svg" class="#{classes}" viewBox="0 0 20 20" fill="currentColor">
            <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
          </svg>
        SVG
      when :back
        <<~SVG.html_safe
          <svg xmlns="http://www.w3.org/2000/svg" class="#{classes}" viewBox="0 0 20 20" fill="currentColor">
            <path fill-rule="evenodd" d="M9.707 16.707a1 1 0 01-1.414 0l-6-6a1 1 0 010-1.414l6-6a1 1 0 011.414 1.414L5.414 9H17a1 1 0 110 2H5.414l4.293 4.293a1 1 0 010 1.414z" clip-rule="evenodd" />
          </svg>
        SVG
      end
    end
  end
end
