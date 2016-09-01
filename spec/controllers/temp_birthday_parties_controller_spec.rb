require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

RSpec.describe TempBirthdayPartiesController, type: :controller do

  # This should return the minimal set of attributes required to create a valid
  # TempBirthdayParty. As you add validations to TempBirthdayParty, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    skip("Add a hash of attributes valid for your model")
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # TempBirthdayPartiesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    it "assigns all temp_birthday_parties as @temp_birthday_parties" do
      temp_birthday_party = TempBirthdayParty.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:temp_birthday_parties)).to eq([temp_birthday_party])
    end
  end

  describe "GET #show" do
    it "assigns the requested temp_birthday_party as @temp_birthday_party" do
      temp_birthday_party = TempBirthdayParty.create! valid_attributes
      get :show, {:id => temp_birthday_party.to_param}, valid_session
      expect(assigns(:temp_birthday_party)).to eq(temp_birthday_party)
    end
  end

  describe "GET #new" do
    it "assigns a new temp_birthday_party as @temp_birthday_party" do
      get :new, {}, valid_session
      expect(assigns(:temp_birthday_party)).to be_a_new(TempBirthdayParty)
    end
  end

  describe "GET #edit" do
    it "assigns the requested temp_birthday_party as @temp_birthday_party" do
      temp_birthday_party = TempBirthdayParty.create! valid_attributes
      get :edit, {:id => temp_birthday_party.to_param}, valid_session
      expect(assigns(:temp_birthday_party)).to eq(temp_birthday_party)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new TempBirthdayParty" do
        expect {
          post :create, {:temp_birthday_party => valid_attributes}, valid_session
        }.to change(TempBirthdayParty, :count).by(1)
      end

      it "assigns a newly created temp_birthday_party as @temp_birthday_party" do
        post :create, {:temp_birthday_party => valid_attributes}, valid_session
        expect(assigns(:temp_birthday_party)).to be_a(TempBirthdayParty)
        expect(assigns(:temp_birthday_party)).to be_persisted
      end

      it "redirects to the created temp_birthday_party" do
        post :create, {:temp_birthday_party => valid_attributes}, valid_session
        expect(response).to redirect_to(TempBirthdayParty.last)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved temp_birthday_party as @temp_birthday_party" do
        post :create, {:temp_birthday_party => invalid_attributes}, valid_session
        expect(assigns(:temp_birthday_party)).to be_a_new(TempBirthdayParty)
      end

      it "re-renders the 'new' template" do
        post :create, {:temp_birthday_party => invalid_attributes}, valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested temp_birthday_party" do
        temp_birthday_party = TempBirthdayParty.create! valid_attributes
        put :update, {:id => temp_birthday_party.to_param, :temp_birthday_party => new_attributes}, valid_session
        temp_birthday_party.reload
        skip("Add assertions for updated state")
      end

      it "assigns the requested temp_birthday_party as @temp_birthday_party" do
        temp_birthday_party = TempBirthdayParty.create! valid_attributes
        put :update, {:id => temp_birthday_party.to_param, :temp_birthday_party => valid_attributes}, valid_session
        expect(assigns(:temp_birthday_party)).to eq(temp_birthday_party)
      end

      it "redirects to the temp_birthday_party" do
        temp_birthday_party = TempBirthdayParty.create! valid_attributes
        put :update, {:id => temp_birthday_party.to_param, :temp_birthday_party => valid_attributes}, valid_session
        expect(response).to redirect_to(temp_birthday_party)
      end
    end

    context "with invalid params" do
      it "assigns the temp_birthday_party as @temp_birthday_party" do
        temp_birthday_party = TempBirthdayParty.create! valid_attributes
        put :update, {:id => temp_birthday_party.to_param, :temp_birthday_party => invalid_attributes}, valid_session
        expect(assigns(:temp_birthday_party)).to eq(temp_birthday_party)
      end

      it "re-renders the 'edit' template" do
        temp_birthday_party = TempBirthdayParty.create! valid_attributes
        put :update, {:id => temp_birthday_party.to_param, :temp_birthday_party => invalid_attributes}, valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested temp_birthday_party" do
      temp_birthday_party = TempBirthdayParty.create! valid_attributes
      expect {
        delete :destroy, {:id => temp_birthday_party.to_param}, valid_session
      }.to change(TempBirthdayParty, :count).by(-1)
    end

    it "redirects to the temp_birthday_parties list" do
      temp_birthday_party = TempBirthdayParty.create! valid_attributes
      delete :destroy, {:id => temp_birthday_party.to_param}, valid_session
      expect(response).to redirect_to(temp_birthday_parties_url)
    end
  end

end