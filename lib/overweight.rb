# frozen_string_literal: true
module Overweight

  def calculate_overweight
  end

  # Total weight in centimeters
  def total_weight(label)
    volumetric_weight = (label['width'] * label['height'] * label['length']) / 5000
    volumetric_weight > label['weight'] ? volumetric_weight : label['weight']
  end


  def real_weight
  end


  def load_labels
    buffer = open("#{Rails.root}/public/labels.json").read
    labels = JSON.parse(buffer)
  end
end