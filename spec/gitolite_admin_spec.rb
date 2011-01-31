require 'gitolite/gitolite_admin'

describe Gitolite::GitoliteAdmin do
  let(:key_data) {"ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6EFlh48tzCnepmggd09sUEM4m1zH3Fs/X6XWm1MAkEnMsD5hFGjkcNabDM8vq9zIRZ05YC6Gxo2plstAf+X4Y636+hyFvbDONB9mRP7DxJhFRaBScSFH60jeTz4ue2ExH3xA1JkaHMcV5vooUqG4BW8Vy/sz8wt/s0aIg9xqkrPOnfvqwunZ/zFUNyL8tC1HY3zGUkRzEVd2yRKaI+DGyRsh8HuYIb2X3NQ0YsU3uGGud7ObmxDbM7WGniyxRVK3lYCvgnTjvdPGi7Xx9QNQz53zLFbklGPZSfpFFHS84qR0Rd/+MnpT50FODhTmXHZtZF1eik09z63GW3YVt4PGoQ== bob@zilla.com"}
  let(:test_repo) { File.join(File.dirname(__FILE__),'test-repo') }


  context 'admin_repository' do
    it 'should initialize with test-repo' do
      FileUtils.remove_dir(File.join(test_repo,'.git'),true) if File.exists?(File.join(test_repo,'.git'))
      Grit::Repo.init(test_repo)
      a = GitoliteAdmin.new(test_repo, {:conf => 'conf/simple.conf'})
      a.gl_admin.should_not eq(nil)
    end

    it 'should add new ssh_key for user jdoe' do
      test_file = File.join(test_repo,'keydir','jdoe.pub')
      File.unlink(test_file) if File.exists?(test_file)

      a = GitoliteAdmin.new(test_repo, {:conf => 'conf/simple.conf'})
      a.add_public_key(key_data,'jdoe')
      a.ssh_keys['jdoe'].first.owner.should eq('jdoe')
      File.exists?(test_file).should eq(true)

      FileUtils.remove_dir(File.join(test_repo,'.git'),true) if File.exists?(File.join(test_repo,'.git'))
      FileUtils.rm Dir.glob(File.join(test_repo,'keydir','jdoe*.pub'))
    end
  end
end