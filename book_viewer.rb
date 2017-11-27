require "sinatra"
require "sinatra/reloader" if development?
require "tilt/erubis"

before do
  @contents = File.readlines('data/toc.txt')
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"
  erb :home
end

get "/chapters/:number" do
  chapter_number = params[:number].to_i
  chapter_name = @contents[chapter_number - 1]
  @title = "Chapter #{chapter_number}: #{chapter_name}"
  @chapter = File.read("data/chp#{chapter_number}.txt")

  erb :chapter
end

get "/show/:name" do
  params[:name]
end

get "/search" do
  erb :search
end

not_found do
  redirect "/"
end

helpers do
  def in_paragraphs(text)
    index = -1
    text.split("\n\n").map do |line|
      index += 1
      "<p id=#{index}>#{line}</p>"
    end.join
  end

  def matching_chapters(query)
    result = []
    @contents.each_with_index do |chapter_title, index|
      chapter_number = index + 1
      chapter = File.read("data/chp#{chapter_number}.txt")
      if chapter.include? query
        result << {chapter: chapter_title, number: chapter_number}
      end
    end

    result
  end

  def matching_paragraphs(chapter_title, chapter_number, query)
    result = []
    chapter = File.read("data/chp#{chapter_number}.txt")
    chapter.split("\n\n").each_with_index do |paragraph, index|
      if paragraph.include? query
        result << {content: paragraph, index: index}
      end
    end

    result
  end

  def bold(query, content)
    content.gsub(query, "<strong>#{query}</strong>")
  end
end
