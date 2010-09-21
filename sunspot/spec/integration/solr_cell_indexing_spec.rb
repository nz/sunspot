require File.join(File.dirname(__FILE__), 'spec_helper')

describe "Rich document indexing and search" do
  before :all do
    filename = File.expand_path(File.join(File.dirname(File.dirname(__FILE__)), 'test_docs/TestPDF.pdf'))
    @rich_text_post = RichTextPost.new(:title => 'test rtd', :rich_attachment => filename)
  end

  it 'indexes a rich document from a complex object' do
    Sunspot.index!(@rich_text_post)
  end

  it 'indexes a rich document and finds the title' do
    Sunspot.index!(@rich_text_post)
    Sunspot.search(RichTextPost) { with(:title, 'test rtd')}.results.should_not be_empty
  end

  it 'indexes a rich document and finds the keyword content' do
    Sunspot.index!(@rich_text_post)
    Sunspot.search(RichTextPost) { keywords "lorem" }.results.should_not be_empty
  end

  it 'indexes a rich document and finds the attachment content' do
    Sunspot.index!(@rich_text_post)
    Sunspot.search(RichTextPost) { keywords "lorem", :fields => [:rich_attachment]}.results.should_not be_empty
  end

  it 'indexes a rich document and does not find content that is not in the attachment' do
    Sunspot.index!(@rich_text_post)
    Sunspot.search(RichTextPost) { keywords "lorem", :fields => [:title]}.results.should be_empty
  end

  it 'find matches in multiple documents' do
    filename = File.expand_path(File.join(File.dirname(File.dirname(__FILE__)), 'test_docs/JustAnotherTest.pdf'))
    rich_text_post = RichTextPost.new(:title => 'test 2', :rich_attachment => filename)
    Sunspot.index!(@rich_text_post)
    Sunspot.index!(rich_text_post)
    Sunspot.search(RichTextPost) { keywords "test"}.results.length.should > 1
  end

end
