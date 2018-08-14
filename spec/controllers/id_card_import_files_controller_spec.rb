require 'rails_helper'

describe IdCardImportFilesController do
  describe 'GET index' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'returns a success status codea' do
        subject(:index) do
          get :index
        end

        expect(response).to have_http_status(:ok)
      end
    end
  end
end