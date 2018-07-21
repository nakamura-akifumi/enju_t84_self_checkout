require 'rails_helper'

describe SelfIccardController do
  describe 'POST translate_from_tag' do
    describe 'When logged in as Administrator' do

      it 'assigns the requested library as @library' do
        subject(:translate_from_tag) do
          post :translate_from_tag, params: { id: 1 }
        end

        it { expect(response.status).to eq 200 }

      end
    end
  end
end