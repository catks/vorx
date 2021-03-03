RSpec.describe Vorx::Store do
  let(:instance) { described_class.new(store_folder.to_s) }

  let(:store_folder) { Pathname.new('tmp/vorx/storage') }
  let(:repo_folder) { store_folder.join('myrepo@master') }
  let(:git_repo) { TestRemoteRepository.new('myrepo', base_directory: store_folder) }
  let(:git_reference) { 'http://gitserver/myrepo.git' }
  let(:git_reference_2) { 'http://gitserver/myrepo2.git' }

  describe '#fetch' do
    def fetch
      instance.fetch(git_reference)
    end


    after do
      store_folder.rmtree
    end

    context 'when repository is not fetched' do
      it 'clone the repository' do
        expect { fetch }.to change { repo_folder.exist? }.from(false).to(true)
        expect(repo_folder.join('test.yml').read)
          .to eq(
            Vorx.root_path.join('docker/git_server/repos/myrepo/test.yml').read
          )
      end

      it 'sets the repository as cloned' do
        expect { fetch }.to change { instance.find(git_reference)&.cloned? }.to(true)
      end
    end

    context 'when repository exists' do
      before do
        fetch

        git_repo.add_file('new_file', content: 'New File')

        git_repo.git.config('user.name', 'Teste Testador')
        git_repo.git.config('user.email', 'test@email.com')
        git_repo.git.add('new_file')
        git_repo.git.commit('New File')
        git_repo.git.push
        git_repo.reset_local

        instance.reload
      end

      after do
        git_repo.reset_all
      end

      it 'update the repository' do
        fetch
        expect(repo_folder.join('new_file').read)
          .to eq(
            'New File'
          )
      end
    end
  end

  describe '#delete' do
    def delete
      instance.delete(git_reference)
    end

    context 'when the repository is added' do
      before do
        instance.add(git_reference)
      end

      it 'delete the repository' do
        expect { delete }.to change { instance.find(git_reference) }.to(nil)
      end

      context 'and cloned' do
        before do
          instance.fetch(git_reference)
        end

        after do
          store_folder.rmtree
        end

        it 'delete the repository' do
          expect { delete }.to change { instance.find(git_reference) }.to(nil)
        end

        it 'delete the repository folder' do
          repo = instance.find(git_reference)

          repo_path = store_folder.join(repo.folder_name)

          expect { delete }.to change { repo_path.exist? }.from(true).to(false)
        end
      end
    end
  end

  describe '#delete_all' do
    def delete_all
      instance.delete_all
    end

    context 'when multiple repositories is added' do
      before do
        instance.add(git_reference)
        instance.add(git_reference_2)
      end

      it 'delete all repositories' do
        expect { delete_all }.to change { instance.all.size }.from(2).to(0)
      end

      context 'and cloned' do
        before do
          instance.fetch(git_reference)
          instance.fetch(git_reference_2)
        end

        after do
          store_folder.rmtree
        end

        it 'delete all repositories' do
          expect { delete_all }.to change { instance.all.size }.from(2).to(0)
        end

        it 'delete the repository folder' do
          repos = instance.all

          delete_all

          repos.each do |repo|
            repo_path = store_folder.join(repo.folder_name)
            expect(repo_path).to_not exist
          end
        end
      end
    end
  end
end
