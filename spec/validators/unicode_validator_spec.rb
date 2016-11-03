require_relative '../../app/validators/unicode_validator'

RSpec.describe UnicodeValidator do
  describe '#valid?' do
    subject(:valid?) { described_class.new(value).valid? }

    context 'when domain name is in utf-8' do
      let(:value) { 'äri.ee'.encode('utf-8') }

      it 'returns true' do
        expect(valid?).to be true
      end
    end

    context 'when domain name is not in utf-8' do
      let(:value) { 'äri.ee'.encode('iso-8859-1') }

      it 'returns false' do
        expect(valid?).to be false
      end
    end
  end
end
