class ContactsController < ApplicationController

  def index
    @contacts = Contact.all
  end

  def new
    @contact = Contact.new
  end

  def create
    @contact = Contact.new(params.require(:contact).permit(:name, :mobile, :message))
    if @contact.save
      redirect_to root_url, notice: '申请提交成功, 请等待我们联系您！'
    else
      render :new
    end
  end

  def destroy
    @contact = Contact.find(params[:id])
    @contact.destroy
    redirect_to contacts_url, notice: '成功删除了提交信息.'
  end
end
