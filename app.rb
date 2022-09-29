require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require 'open-uri'
require 'tempfile'
require 'sinatra/json'
require './models.rb'

enable :sessions

helpers do
    def current_user
        User.find_by(id: session[:user])
    end
end

before do
    Dotenv.load
    Cloudinary.config do |config|
        config.cloud_name = ENV['CLOUD_NAME']
        config.api_key = ENV['CLOUDINARY_API_KEY']
        config.api_secret = ENV['CLOUDINARY_API_SECRET']
    end
end

get '/' do
    if current_user.nil?
        @contributions = Contribution.none
    else
        @contributions = current_user.contributions
    end
  erb :index
end

get '/signup' do
   erb :sign_up 
end

post '/signup' do
    image_url = ''
    if params[:file]
        image = params[:file]
        tempfile = image[:tempfile]
        upload = Cloudinary::Uploader.upload(tempfile.path)
        image_url = upload['url']
    end
    
    user = User.create(
        name: params[:name],
        password: params[:password],
        password_confirmation: params[:password_confirmation],
        image: image_url
    )
    if user.persisted?
        session[:user] = user.id
    end
    redirect '/'
end

get '/signin' do
    erb :sign_in
end

post '/signin' do
    user = User.find_by(name: params[:name])
    if user && user.authenticate(params[:password])
        session[:user] = user.id
    end
    redirect '/'
end

get '/signout' do
    session[:user] = nil
    redirect '/'
end

get '/contributions/new' do
    erb :index
end

post '/contributions' do
    item_image_url = ''
    if params[:file]
        item_image = params[:file]
        tempfile = item_image[:tempfile]
        upload = Cloudinary::Uploader.upload(tempfile.path)
        item_image_url = upload['url']
    end
    
    
    current_user.contributions.create({
        user_name: params[:user_name],
        shop_name: params[:shop_name],
        item_name: params[:item_name],
        item_url: params[:item_url],
        message: params[:message],
        item_image: item_image_url
    })
    
    redirect '/home'
end

get '/home' do
    erb :home
end

get '/contributions/:id/delete' do
    contribution = Contribution.find(params[:id])
    contribution.destroy
    erb :home
end

get '/contributions/:id/edit' do
    @contributions = Contribution.find(params[:id])
    erb :edit
end

post '/contributions/:id/edit' do
    contribution = Contribution.find(params[:id])
    contribution.message = params[:message] 
    contribution.save
    redirect '/home'
end

get '/contributions/:id/like' do
    contribution = Contribution.find(params[:id])
    current_user.likes.create(
        user_id: session[:user],
        contribution_id: params[:id]
        )
    redirect '/'
end

get '/contributions/:id/dislike' do
    contribution = current_user.likes.find_by(contribution_id: params[:id])
    puts contribution.id
    contribution.destroy
    contribution.save
    redirect '/'
end

get '/login_to_like' do
    erb :login_to_like, :layout => nil
end

post '/contributions/:id/comment/done' do
    contribution = Contribution.find(params[:id])
    Comment.create(
        user_id: session[:user],
        contribution_id: params[:id],
        statement: params[:statement]
        )
    redirect '/'
end

post '/contributions/:id/comment' do
  contribution = Contribution.find(params[:id])
  erb :index
end

get '/login_to_comment' do
    erb :login_to_comment, :layout => nil
end