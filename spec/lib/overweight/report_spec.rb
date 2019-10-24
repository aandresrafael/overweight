require 'rails_helper'

RSpec.describe Overweight::Report  do
  let(:overweight_report) { Overweight::Report.new }

  describe '#overweight' do
    context 'when weight used is greather than real weight' do
      it 'should calculate overweight' do
        expect(overweight_report.overweight(3.5, 3)).to eq(1)
      end
    end

    context 'when weight used is less than real weight' do
      it 'should return zero' do
        expect(overweight_report.overweight(2.9, 3)).to be_zero
      end
    end
  end

  describe '#total_weight' do
    context 'when dimentions is greather than the weight' do
      let(:dimentions) { { 'width'=> 20, 'height'=> 30, 'length'=> 50, 'weight'=> 2 }}

      it 'should return volumetric weight (width * height * length / 5000)' do
        expect(overweight_report.total_weight(dimentions)).to eq(6)
      end
    end

    context 'when dimentions is less than the weight should return weight' do
      let(:dimentions) { { 'width'=> 20, 'height'=> 30, 'length'=> 20, 'weight'=> 3 }}

      it 'should return the weight' do
        expect(overweight_report.total_weight(dimentions)).to eq(3)
      end
    end
  end

  describe '#real_weight' do
    let(:track_reponse_double) do
      double(
        details: {
          package_weight: {
            value: 3,
            units: 'LB'
          }
        }
      )
    end

    context 'when track number exists in fedex' do
      before do
        allow(overweight_report).to receive_message_chain("fedex.track") { [track_reponse_double] }
      end

      it 'should return real weight in KG' do
        expect(overweight_report.real_weight('1111').round(2)).to eq(1.36)
      end
    end

    context 'when track number does not exists' do
      before do
        allow(overweight_report).to receive_message_chain("fedex.track") { raise }
      end

      it 'should return zero' do
        expect(overweight_report.real_weight('1111')).to eq(0)
      end
    end
  end
end
