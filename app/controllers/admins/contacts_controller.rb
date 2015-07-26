class Admins::ContactsController < ApplicationController
  def index
    @contacts = Contact.all
  end
end
