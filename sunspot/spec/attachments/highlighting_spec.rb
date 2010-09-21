require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'attachment keyword highlighting' do
  before :all do
    test_docs = File.expand_path(File.join(File.dirname(File.dirname(__FILE__)), 'test_docs'))
    @posts = []
    @posts << RichTextPost.new(:rich_attachment => File.join(test_docs, 'TestPDF.pdf'))
    @posts << RichTextPost.new(:rich_attachment => File.join(test_docs, 'JustAnotherTest.pdf'), :title => "This is the title")
    Sunspot.index!(*@posts)
    @search_result = Sunspot.search(RichTextPost) do
      keywords 'lorem' do
        highlight :max_snippets => 100
      end
    end
  end

  it 'should include highlights in the results' do
    @search_result.hits.first.highlights.length.should > 0
  end

  it 'should return formatted highlight fragments' do
    @search_result.hits.first.highlights(:rich_attachment).should_not be_empty
    @search_result.hits.first.highlights(:rich_attachment).first.format.should == "This is a test \nPDF file.    <em>Lorem</em> ipsum dolor sit amet, consectetur adipiscing elit"
  end

  it 'should be empty for non-keyword searches' do
    search_result = Sunspot.search(RichTextPost){ with :title, "This is the title" }
    search_result.hits.first.highlights.should be_empty
  end

  it 'should return multple hits for multiple occurances' do
    @search_result.hits.first.highlights(:rich_attachment).length.should > 1
  end
end
