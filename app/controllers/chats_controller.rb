class ChatsController < ApplicationController
  include AuthenticatedSystem

  layout 'chats', :only => 'index'
  before_filter :login_required
  skip_before_filter :verify_authenticity_token, :only => :show

  # GET /chats
  # GET /chats.xml
  def index
    @chats = Chat.find(:all, :order => "id DESC", :limit => 10)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @chats }
    end
  end

  # GET /chats/1
  # GET /chats/1.xml
  def show
    @chat = Chat.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @chat }
    end
  end

  # GET /chats/new
  # GET /chats/new.xml
  def new
    @chat = Chat.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @chat }
    end
  end

  # GET /chats/1/edit
  def edit
    @chat = Chat.find(params[:id])
  end

  # POST /chats
  # POST /chats.xml
  def create
    @chat = Chat.create(params[:chat])

    # 追加されたメッセージを表示するためのHTML
    content = render_component_as_string :action => 'show', :id => @chat.id

    # ↑のメッセージをリストに追加するためのJavaScript
    javascript = render_to_string :update do |page|
      page.insert_html :top, 'chat-list', content
    end

    # チャネル'shot_chat'をリスンしているクライアントに↑のJSをプッシュ
    Meteor.shoot 'shot_chat', javascript

    render :nothing => true
  end

  # PUT /chats/1
  # PUT /chats/1.xml
  def update
    @chat = Chat.find(params[:id])

    respond_to do |format|
      if @chat.update_attributes(params[:chat])
        flash[:notice] = 'Chat was successfully updated.'
        format.html { redirect_to(@chat) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @chat.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /chats/1
  # DELETE /chats/1.xml
  def destroy
    @chat = Chat.find(params[:id])
    @chat.destroy

    respond_to do |format|
      format.html { redirect_to(chats_url) }
      format.xml  { head :ok }
    end
  end
end
