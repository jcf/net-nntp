require 'spec_helper'

describe Net::NNTP do
  let(:socket) { double('socket').as_null_object }

  let(:nntp) do
    Net::NNTP.new('news.example.com')
  end

  before(:each) do
    Socket.stub(pack_sockaddr_in: socket)
    Socket.stub(new: socket)
  end

  describe '#close' do
    it 'closes the socket' do
      socket.should_receive(:close)
      nntp.close
    end
  end

  describe '#closed?' do
    it 'closes the socket' do
      socket.stub(closed?: true)
      nntp.should be_closed
    end
  end

  describe '#mode_reader' do
    it 'asks for mode reader' do
      socket.should_receive(:write).with("MODE READER\r\n")
      nntp.mode_reader
    end
  end

  describe '#listgroup' do
    context 'with a group of comp.lang.ruby' do
      it 'asks to list the comp.lang.ruby group' do
        socket.should_receive(:write).with("LISTGROUP comp.lang.ruby\r\n")
        nntp.listgroup('comp.lang.ruby')
      end
    end
  end

  describe '#article' do
    context 'with ID 11' do
      it 'asks for the article with ID 11' do
        socket.should_receive(:write).with("ARTICLE 11\r\n")
        nntp.article(11)
      end
    end
  end

  describe '#head' do
    context 'with an ID of 11' do
      it 'asks for head with ID 11' do
        socket.should_receive(:write).with("HEAD 11\r\n")
        nntp.head(11)
      end
    end

    # context 'with a 221 response code' do
    #   it 'returns a parsed article' do
    #     Net::NNTP::Article.stub(parse: 'article')
    #     socket.stub(write: true)
    #     nntp.stub_chain(:response, :code).and_return(221)
    #     nntp.head(11).should == 'article'
    #   end
    # end
  end

  describe '#group' do
    context 'with a newsgroup of comp.lang.ruby' do
      it 'asks for group with comp.lang.ruby' do
        socket.should_receive(:write).with("GROUP comp.lang.ruby\r\n")
        nntp.group('comp.lang.ruby')
      end
    end
  end

end
