require 'gitolite/ssh_key'
include Gitolite

describe Gitolite::SSHKey do
  let(:key_dir) { File.join(File.dirname(__FILE__),'test-repo','keydir') }
  describe '#owner' do
    it 'owner should be bob for bob.pub' do
      key = File.join(key_dir, 'bob.pub')
      s = SSHKey.new(key)
      s.owner.should == 'bob'
    end

    it 'owner should be bob for bob@desktop.pub' do
      key = File.join(key_dir, 'bob@desktop.pub')
      s = SSHKey.new(key)
      s.owner.should == 'bob'
    end

    it 'owner should be bob@zilla.com for bob@zilla.com.pub' do
      key = File.join(key_dir, 'bob@zilla.com.pub')
      s = SSHKey.new(key)
      s.owner.should == 'bob@zilla.com'
    end

    it 'owner should be bob@zilla.com for bob@zilla.com@desktop.pub' do
      key = File.join(key_dir, 'bob@zilla.com@desktop.pub')
      s = SSHKey.new(key)
      s.owner.should == 'bob@zilla.com'
    end

    it 'owner should be jakub123 for jakub123.pub' do
      key = File.join(key_dir, 'jakub123.pub')
      s = SSHKey.new(key)
      s.owner.should == 'jakub123'
    end

    it 'owner should be jakub123@foo.net for jakub123@foo.net.pub' do
      key = File.join(key_dir, 'jakub123@foo.net.pub')
      s = SSHKey.new(key)
      s.owner.should == 'jakub123@foo.net'
    end

    it 'owner should be joe@sch.ool.edu for joe@sch.ool.edu' do
      key = File.join(key_dir, 'joe@sch.ool.edu.pub')
      s = SSHKey.new(key)
      s.owner.should == 'joe@sch.ool.edu'
    end

    it 'owner should be joe@sch.ool.edu for joe@sch.ool.edu@desktop.pub' do
      key = File.join(key_dir, 'joe@sch.ool.edu@desktop.pub')
      s = SSHKey.new(key)
      s.owner.should == 'joe@sch.ool.edu'
    end
  end

  describe '#location' do
    it 'location should be "" for bob.pub' do
      key = File.join(key_dir, 'bob.pub')
      s = SSHKey.new(key)
      s.location.should == ''
    end

    it 'location should be "desktop" for bob@desktop.pub' do
      key = File.join(key_dir, 'bob@desktop.pub')
      s = SSHKey.new(key)
      s.location.should == 'desktop'
    end

    it 'location should be "" for bob@zilla.com.pub' do
      key = File.join(key_dir, 'bob@zilla.com.pub')
      s = SSHKey.new(key)
      s.location.should == ''
    end

    it 'location should be "desktop" for bob@zilla.com@desktop.pub' do
      key = File.join(key_dir, 'bob@zilla.com@desktop.pub')
      s = SSHKey.new(key)
      s.location.should == 'desktop'
    end

    it 'location should be "" for jakub123.pub' do
      key = File.join(key_dir, 'jakub123.pub')
      s = SSHKey.new(key)
      s.location.should == ''
    end

    it 'location should be "" for jakub123@foo.net.pub' do
      key = File.join(key_dir, 'jakub123@foo.net.pub')
      s = SSHKey.new(key)
      s.location.should == ''
    end

    it 'location should be "" for joe@sch.ool.edu' do
      key = File.join(key_dir, 'joe@sch.ool.edu.pub')
      s = SSHKey.new(key)
      s.location.should == ''
    end

    it 'location should be "desktop" for joe@sch.ool.edu@desktop.pub' do
      key = File.join(key_dir, 'joe@sch.ool.edu@desktop.pub')
      s = SSHKey.new(key)
      s.location.should == 'desktop'
    end
  end

  describe '#keys' do
    it 'should load ssh key properly' do
      key = File.join(key_dir, 'bob.pub')
      s = SSHKey.new(key)
      parts = File.read(key).split #should get type, blob, email

      s.type.should == parts[0]
      s.blob.should == parts[1]
      s.email.should == parts[2]
    end
  end

  describe '#email' do
    it 'should use owner if email is missing' do
      key = File.join(key_dir, 'jakub123@foo.net.pub')
      s = SSHKey.new(key)
      s.owner.should == s.email
    end
  end

  describe '#create' do
    let(:key_data) {"ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6EFlh48tzCnepmggd09sUEM4m1zH3Fs/X6XWm1MAkEnMsD5hFGjkcNabDM8vq9zIRZ05YC6Gxo2plstAf+X4Y636+hyFvbDONB9mRP7DxJhFRaBScSFH60jeTz4ue2ExH3xA1JkaHMcV5vooUqG4BW8Vy/sz8wt/s0aIg9xqkrPOnfvqwunZ/zFUNyL8tC1HY3zGUkRzEVd2yRKaI+DGyRsh8HuYIb2X3NQ0YsU3uGGud7ObmxDbM7WGniyxRVK3lYCvgnTjvdPGi7Xx9QNQz53zLFbklGPZSfpFFHS84qR0Rd/+MnpT50FODhTmXHZtZF1eik09z63GW3YVt4PGoQ== bob@zilla.com"}

    it 'should fail when trying to overwrite existing file' do
      file_name = File.join(key_dir, 'bob.pub')
      begin
        SSHKey.create(file_name, key_data)
      rescue
        rescued = true
      end
      fail "should have failed before" unless rescued
    end

    it 'should create new key file from key data' do
      file_name = File.join(key_dir, 'test.pub')
      s = SSHKey.create(file_name, key_data)

      File.unlink(file_name)
    end
  end

  describe '#file_name' do
    it 'should support simple file names' do
      SSHKey.file_name('jdoe').should eq('jdoe.pub')
    end

    it 'should support e-mail adresses as username' do
      SSHKey.file_name('jdoe@example.com').should eq('jdoe@example.com.pub')
    end

    it 'should handle locations' do
      SSHKey.file_name('jdoe@example.com', 'machine1').should eq('jdoe@example.com@machine1.pub')
    end
  end
end
