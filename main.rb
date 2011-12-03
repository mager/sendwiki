require 'rubygems'
require 'sinatra'
require 'mongo_mapper'
require 'pony'
require 'nokogiri'
require 'open-uri'
require './model'

TPMI_SMTP_OPTIONS = {
    :address        => "smtp.sendgrid.net",
    :port           => "587",
    :authentication => :plain,
    :user_name      => 'andrew@mager.co',
    :password       => ENV['SENDGRID_PASSWORD'],
    :domain         => 'www.sendwiki.com',
}

def send_email(to, subject, html_body)
  Pony.mail(:to => to, :from => 'SendWiki <email@sendwiki.com>',
    :subject => subject,
    :html_body => html_body,
    :via => :smtp, :via_options => TPMI_SMTP_OPTIONS
  )
end

get '/' do
  erb :main
end

post '/' do
  email = params[:email]
  wikipedia_article = params[:article]

  article_object = Article.create({
    :article => wikipedia_article,
    :email => email
  })
  article_object.save

  # parse the HTML from Wikipedia
  article = Nokogiri::HTML(open(wikipedia_article))
  subject = article.css('#content h1')

  # remove stuff that doesn't look great in email
  article.css('#coordinates').remove
  article.css('#toc').remove
  article.css('#jump-to-nav').remove
  article.css('.infobox').remove
  article.css('img').remove
  article.css('script').remove
  article.css('.editsection').remove
  article.css('.navbox').remove

  # Fix links
  article.css('#bodyContent a').each do |a|
    a['href'] = "http://en.wikipedia.org/#{a['href']}"
  end

  content = article.css('#bodyContent').to_html
  
  send_email(email, subject.text, content)
  redirect '/sent'
end

get '/sent' do
  erb :sent
end
