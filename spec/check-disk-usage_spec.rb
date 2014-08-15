require "rspec"

describe "ruby check-disk-usage.rb" do
  before do
    system "dd if=/dev/zero of=#{Dir.pwd}/tempfile bs=1m count=5 > /dev/null 2>&1"
  end

  let(:result) {`#{self.class.description}`}
  let(:result_status) {system "#{self.class.description} > /dev/null 2>&1"}

  it {result.match /You must supply -p PATH!/}
  it {expect(result_status).to be false}

  context "#{self.description} --path #{Dir.pwd}/tempfile" do
    it {result.match /OK/}
    it {expect(result_status).to be true}

    context "#{self.description} --critical-over 3" do
      it {result.match /CRITICAL/}
      it {expect(result_status).to be false}

      context "#{self.description} --warning-over 2" do
        it {result.match /CRITICAL/}
      end
    end

    context "#{self.description} --critical-over 10" do
      it {result.match /OK/}

      context "#{self.description} --warning-over 4" do
        it {result.match /WARNING/}
        it {expect(result_status).to be false}
      end
    end

    context "#{self.description} --warning-over 3" do
      it {result.match /WARNING/}
    end

    context "#{self.description} --warning-over 10" do
      it {result.match /OK/}
    end
  end

  context "#{self.description} --path #{Dir.pwd}/does_not_exist > /dev/null 2>&1" do
    it {result.match /UNKNOWN/}
    it {expect(result_status).to be false}
  end

  after do
    system "rm -f #{Dir.pwd}/tempfile > /dev/null"
  end
end
