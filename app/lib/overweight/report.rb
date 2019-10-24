# frozen_string_literal: true
require 'fedex'
require 'open-uri'

module Overweight
  class Report
    attr_accessor :fedex

    def initialize
      @fedex ||= Fedex::Shipment.new(
        key: 'jfjwKS65xft8r8mh',
        password: 'QYrbniTyMafyj4LXm4tV7nsq5',
        account_number: '802388543',
        meter: '119147906',
        mode: 'development'
      )
    end

    def generate
      labels = load_labels
      report = []
      labels.each do |label|
        total_weight = total_weight(label['parcel'])
        real_weight = real_weight(label['tracking_number'])
        overweight = real_weight.zero? ? 0 : overweight(total_weight, real_weight)
        note = real_weight.zero? ? 'This tracking number cannot be found in fedex' : ''

        report << {
          tracking_number: label['tracking_number'],
          used_weight: total_weight.round(2),
          real_weight: real_weight.round(2),
          overweight: overweight,
          note: note
        }
      end
      report
    end

    # Total weight in centimeters
    def total_weight(dimensions)
      volumetric_weight = (dimensions['width'] * dimensions['height'] * dimensions['length']) / 5000
      volumetric_weight > dimensions['weight'] ? volumetric_weight : dimensions['weight']
    end

    #Real weight from fedex tracking info in KG
    def real_weight(tracking_number)
      begin
        tracking_info = fedex.track(tracking_number: tracking_number)
        package_weight = tracking_info.first.details[:package_weight]
        package_weight[:units] == 'LB' ? package_weight[:value].to_f/2.2046 : package_weight[:value]
      rescue
        0
      end
    end

    def overweight(total_weight, real_weight)
      diff = total_weight - real_weight
      diff > 0 ? diff.ceil : 0
    end

    def load_labels
      buffer = open("#{Rails.root}/public/labels.json").read
      JSON.parse(buffer)
    end
  end
end
