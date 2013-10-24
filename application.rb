require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'data_mapper'
require 'json'
require File.join(File.dirname(__FILE__), 'lib/review')
require File.join(File.dirname(__FILE__), 'environment')

configure do
  DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/dev.db")
  DataMapper.finalize.auto_upgrade!
end

error do
  e = request.env['sinatra.error']
  Kernel.puts e.backtrace.join("\n")
  'Application error'
end

# root page
get '/' do
    'Hello World'
end

# reviews
get '/reviews' do
    if review = Review.all
        content_type :json
        review.to_json
    else
        json_status 404, "No reviews found"
    end
end

get '/review/:id' do
    begin
        if review = Review.get(params['id'])
            content_type :json
            review.to_json
        else
            json_status 404, "Review not found"
        end
    rescue => e
        json_status 400, e.message
    end
end

post '/review' do
    begin
        review = Review.new(:name => params['name'], :text => params['text'])
        if review.save
            review.to_json
        else
            error 400, { :errors => review.errors.to_h }.to_json
        end
    rescue => e
        error 400, e.message.to_json
    end
end

patch '/review/:id' do
    begin
        review = Review.get(params[:id])
        if review.update!(:name => params['name'], :text => params['text'])
            review.to_json
            status 204
        else
            error 400, { :errors => review.errors.to_h }.to_json
        end
    rescue => e
        error 400, e.message.to_json
    end
end

delete '/review/:id' do
    begin
        review = Review.get(params[:id])
        if(review.destroy!)
            status 204
        else
            error 400, { :errors => review.errors.to_h }.to_json
        end
    rescue => e
        error 400, e.message.to_json
    end
end
